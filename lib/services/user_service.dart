import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserService {
  final String baseUrl = 'http://192.168.1.251:8080/api';

  /// Lấy token từ SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Lấy userId từ SharedPreferences
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  /// Lấy thông tin người dùng từ API
  Future<User?> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        print('⚠️ Token null');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(utf8.decode(response.bodyBytes));

        if (userData != null && userData['id'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userData['id'].toString());
          print('✅ Đã lưu user_id: ${userData['id']}');
          return User.fromJson(userData);
        } else {
          print('⚠️ Không tìm thấy ID trong dữ liệu người dùng');
          return null;
        }
      } else {
        print('❌ Lỗi API: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  /// Cập nhật thông tin người dùng
  Future<User?> updateUserProfile(User user) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('⚠️ Token null');
        return null;
      }

      // Chuẩn bị dữ liệu user (loại bỏ các trường không cần thiết)
      Map<String, dynamic> userJson = user.toJson();
      userJson.remove('createdBy');
      userJson.remove('updatedBy');
      userJson.remove('isDeleted');
      userJson.remove('lastLogin');
      userJson.remove('userRoles');
      userJson.remove('socialAccounts');

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/users/save'));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'application/json';
      request.fields['user'] = json.encode(userJson);

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final updatedUserData = json.decode(responseData);
        print('✅ Cập nhật thành công: ${updatedUserData['id']}');
        return User.fromJson(updatedUserData);
      } else {
        print('❌ Lỗi cập nhật: ${response.statusCode} - $responseData');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi cập nhật thông tin: $e');
      return null;
    }
  }
}
