import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:medical_storage/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'cart_service.dart';
import '../models/user.dart';
import 'base_service.dart';

class UserLogin {
  final String? email;
  final String? password;
  final String? token;
  final String? userId;

  // Sử dụng constructor với tham số không bắt buộc có tên
  const UserLogin({
    this.email,
    this.password,
    this.token,
    this.userId,
  });

  // Factory constructor để tạo đối tượng từ JSON
  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      email: json['email'],
      token: json['token'],
      userId: json['userId'],
    );
  }

  // Tạo bản sao của đối tượng với các giá trị mới (immutable pattern)
  UserLogin copyWith({
    String? email,
    String? password,
    String? token,
    String? userId,
  }) {
    return UserLogin(
      email: email ?? this.email,
      password: password ?? this.password,
      token: token ?? this.token,
      userId: userId ?? this.userId,
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'token': token,
      'userId': userId
    };
  }

  @override
  String toString() => 'UserLogin(email: $email, token: ${token != null ? '***' : 'null'}, userId: $userId)';
}

// Các khóa cho SharedPreferences
class AuthKeys {
  static const String authToken = 'auth_token';
  static const String userEmail = 'user_email';
  static const String userId = 'user_id';
}

// Các endpoint API
class AuthEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String validateToken = '/auth/auth-token';
}

// Kết quả đăng nhập/đăng ký
class AuthResult {
  final UserLogin? user;
  final String? errorMessage;
  final bool success;

  const AuthResult({
    this.user,
    this.errorMessage,
    required this.success,
  });

  // Factory constructor cho trường hợp thành công
  factory AuthResult.success(UserLogin user) => AuthResult(user: user, success: true);

  // Factory constructor cho trường hợp thất bại
  factory AuthResult.failure(String message) => AuthResult(errorMessage: message, success: false);
}

class AuthService extends BaseService<UserLogin> {
  // Đối tượng UserService và CartService
  final UserService _userService = UserService();
  final CartService _cartService = CartService();

  // Cache cho trạng thái đăng nhập
  bool? _cachedLoginState;
  Timer? _loginStateTimer;

  AuthService() : super(
      endpoint: 'auth',
      fromJson: UserLogin.fromJson
  );

  // Hiển thị dialog lỗi
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Lưu thông tin người dùng vào SharedPreferences
  Future<void> _saveUserData(UserLogin user) async {
    final prefs = await SharedPreferences.getInstance();

    if (user.token != null) {
      await prefs.setString(AuthKeys.authToken, user.token!);
    }

    if (user.email != null) {
      await prefs.setString(AuthKeys.userEmail, user.email!);
    }

    if (user.userId != null) {
      await prefs.setString(AuthKeys.userId, user.userId!);
    }
  }

  // Hàm đăng nhập đã tối ưu hóa
  Future<UserLogin> login(String email, String password, BuildContext context) async {
    try {
      // Tạo request đăng nhập
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        String token;
        final prefs = await SharedPreferences.getInstance();

        try {
          // Giải mã phản hồi JSON
          final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
          token = body['token'];
        } catch (e) {
          // Nếu không phải JSON, xử lý như chuỗi token đơn giản
          token = utf8.decode(response.bodyBytes).trim();
        }

        // Tạo đối tượng người dùng đã đăng nhập
        final UserLogin userLogin = UserLogin(email: email, token: token);

        // Lưu thông tin phiên đăng nhập
        await _saveUserData(userLogin);

        // Cập nhật trạng thái đăng nhập
        _cachedLoginState = true;

        // Lấy thông tin hồ sơ người dùng
        await _userService.getUserProfile();

        // Chuyển đến màn hình chính
        Navigator.of(context).pushReplacementNamed('/home');

        return userLogin;
      } else {
        // Xử lý lỗi từ API
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        String errorMessage = errorBody['message'] ?? 'Đăng nhập thất bại';

        // Hiển thị thông báo lỗi
        _showErrorDialog(context, 'Lỗi Đăng Nhập', errorMessage);

        throw Exception(errorMessage);
      }
    } catch (e) {
      // Xử lý lỗi không mong đợi (kết nối, mạng, v.v.)
      final errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      _showErrorDialog(context, 'Lỗi', errorMessage);

      throw Exception(errorMessage);
    }
  }

  // Đăng ký với email và mật khẩu
  Future<AuthResult> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? confirmPassword,
    required BuildContext context,
  }) async {
    try {
      // Xác thực mật khẩu xác nhận
      if (confirmPassword != null && password != confirmPassword) {
        const errorMessage = 'Mật khẩu xác nhận không khớp';
        _showErrorDialog(context, 'Lỗi Đăng Ký', errorMessage);
        return AuthResult.failure(errorMessage);
      }

      // Gửi yêu cầu đăng ký
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Đăng ký thành công, chuyển đến trang đăng nhập
        Navigator.of(context).pushReplacementNamed('/login');

        // Trả về kết quả thành công
        return AuthResult.success(UserLogin(email: email));
      } else {
        // Xử lý lỗi từ API
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        String errorMessage = errorBody['message'] ?? 'Đăng ký thất bại';

        _showErrorDialog(context, 'Lỗi Đăng Ký', errorMessage);
        return AuthResult.failure(errorMessage);
      }
    } catch (e) {
      // Xử lý lỗi ngoại lệ
      final errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      _showErrorDialog(context, 'Lỗi', errorMessage);
      return AuthResult.failure(errorMessage);
    }
  }

  // Lấy token hiện tại
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AuthKeys.authToken);
  }

  // Lấy ID người dùng
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AuthKeys.userId);
  }

  // Lấy email người dùng
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AuthKeys.userEmail);
  }

  // Kiểm tra trạng thái đăng nhập
  Future<bool> isLoggedIn() async {
    // Sử dụng cache nếu có
    if (_cachedLoginState != null) {
      // Đặt lại timer để làm mới cache
      _loginStateTimer?.cancel();
      _loginStateTimer = Timer(const Duration(minutes: 5), () {
        _cachedLoginState = null;
      });
      return _cachedLoginState!;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthKeys.authToken);

    // Kiểm tra token tồn tại
    if (token == null || token.isEmpty) {
      _cachedLoginState = false;
      return false;
    }else{
      return true;
    }
  }

  // Hàm quên mật khẩu
  Future<AuthResult> forgotPassword(String email, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      // Xử lý phản hồi
      if (response.statusCode == 200) {
        String message = 'Đã gửi mã xác nhận đến email của bạn';

        // Cố gắng lấy thông báo từ JSON nếu có
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
            if (body.containsKey('message')) {
              message = body['message'];
            }
          } catch (jsonError) {
            // Nếu không parse được JSON, sử dụng thông báo mặc định
            if (kDebugMode) {
              print('Không thể phân tích phản hồi: $jsonError');
            }
          }
        }

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(10),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );

        // Lưu email để sử dụng ở trang xác nhận
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('reset_email', email);

        // Điều hướng đến trang xác nhận
        Navigator.of(context).pushReplacementNamed('/verifycode');

        return AuthResult.success(UserLogin(email: email));
      } else {
        // Xử lý lỗi
        String errorMessage = 'Không thể gửi yêu cầu đặt lại mật khẩu';

        try {
          if (response.body.isNotEmpty) {
            final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
            errorMessage = errorBody['error'] ?? errorMessage;
          }
        } catch (e) {
          // Giữ thông báo mặc định nếu không parse được JSON
        }

        _showErrorDialog(context, 'Yêu cầu thất bại', errorMessage);
        return AuthResult.failure(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      _showErrorDialog(context, 'Lỗi kết nối', errorMessage);
      return AuthResult.failure(errorMessage);
    }
  }

// Hàm đặt lại mật khẩu
  Future<AuthResult> resetPassword(String verificationCode, String newPassword, BuildContext context) async {
    try {
      // Lấy email đã lưu trước đó
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('reset_email') ?? '';

      if (email.isEmpty) {
        const errorMessage = 'Không tìm thấy thông tin email, vui lòng thực hiện lại từ đầu';
        _showErrorDialog(context, 'Lỗi', errorMessage);
        return AuthResult.failure(errorMessage);
      }

      // Gửi yêu cầu đặt lại mật khẩu với mã xác nhận
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': verificationCode,  // Mã xác nhận từ email
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        // Xử lý phản hồi thành công
        String message = 'Đặt lại mật khẩu thành công';

        try {
          if (response.body.isNotEmpty) {
            final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
            if (body.containsKey('message')) {
              message = body['message'];
            }
          }
        } catch (e) {
          // Giữ thông báo mặc định nếu không parse được JSON
        }

        // Xóa email đã sử dụng
        await prefs.remove('reset_email');

        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(10),
          ),
        );

        // Điều hướng đến trang đăng nhập
        Navigator.of(context).pushReplacementNamed('/login');

        return AuthResult.success(UserLogin());
      } else {
        // Xử lý lỗi
        String errorMessage = 'Không thể đặt lại mật khẩu';

        try {
          if (response.body.isNotEmpty) {
            final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
            errorMessage = errorBody['error'] ?? errorMessage;
          }
        } catch (e) {
          // Giữ thông báo mặc định nếu không parse được JSON
        }

        _showErrorDialog(context, 'Yêu cầu thất bại', errorMessage);
        return AuthResult.failure(errorMessage);
      }
    } catch (e) {
      final errorMessage = 'Có lỗi xảy ra: ${e.toString()}';
      _showErrorDialog(context, 'Lỗi', errorMessage);
      return AuthResult.failure(errorMessage);
    }
  }

  // Đăng xuất
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Xóa giỏ hàng
    Provider.of<CartService>(context, listen: false).clearCart();

    // Xóa thông tin đăng nhập
    await prefs.remove(AuthKeys.authToken);
    await prefs.remove(AuthKeys.userEmail);
    await prefs.remove(AuthKeys.userId);

    // Đặt lại trạng thái cache
    _cachedLoginState = false;

    // Chuyển về trang đăng nhập
    Navigator.of(context).pushReplacementNamed('/login');
  }
}