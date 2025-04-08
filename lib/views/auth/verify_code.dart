import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical_storage/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({Key? key}) : super(key: key);

  @override
  _VerifyCodePageState createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isFormSubmitted = false;

  // Service
  final AuthService _authService = AuthService();

  // Bộ điều khiển animation
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _slideAnimation;

  // Hằng số thiết kế
  final Color _primaryColor = const Color(0xFF0088CC);
  final Color _accentColor = const Color(0xFF4ECDC4);
  final Color _errorColor = const Color(0xFFE74C3C);
  final Color _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadToken();
  }

  // Tải token từ SharedPreferences nếu có
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('reset_token') ?? '';
    if (token.isNotEmpty) {
      setState(() {
        _tokenController.text = token;
      });
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeIn,
        )
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _animationController!,
          curve: Curves.easeOut,
        )
    );

    // Bắt đầu animation
    _animationController!.forward();
  }

  Future<void> _resetPassword() async {
    // Đánh dấu form đã được gửi để hiển thị validation
    setState(() {
      _isFormSubmitted = true;
    });

    if (_formKey.currentState!.validate()) {
      // Ẩn bàn phím
      FocusScope.of(context).unfocus();

      // Hiển thị loading
      setState(() {
        _isLoading = true;
      });

      try {
        // Gọi API đặt lại mật khẩu
        final result = await _authService.resetPassword(
            _tokenController.text.trim(),
            _newPasswordController.text.trim(),
            context
        );

        // Kết quả được xử lý trong hàm resetPassword,
        // hàm đó đã bao gồm việc hiển thị thông báo và điều hướng
      } catch (e) {
        // Xử lý lỗi nếu có ngoại lệ không được bắt trong resetPassword
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Không thể đặt lại mật khẩu: ${e.toString()}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: _errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(10),
            ),
          );
        }
      } finally {
        // Đặt lại trạng thái loading nếu widget vẫn còn mounted
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Kiểm tra animation controller đã được khởi tạo chưa
    if (_animationController == null ||
        _fadeAnimation == null ||
        _slideAnimation == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage("assets/images/bg-auth/bg-fn.jpg"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/bg-auth/bg-fn.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: AnimatedBuilder(
          animation: _animationController!,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation!.value),
              child: Opacity(
                opacity: _fadeAnimation!.value,
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Nội dung chính
                      Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width > 600 ? size.width * 0.15 : 20,
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo và tiêu đề
                              _buildHeader(),
                              const SizedBox(height: 30),
                              // Form chính
                              _buildPasswordResetForm(),
                            ],
                          ),
                        ),
                      ),

                      // Nút quay lại
                      _buildBackButton(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.medical_services_rounded,
              size: 60,
              color: _primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Tên ứng dụng
        Text(
          'THAVP Pharmacity',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Khẩu hiệu
        Text(
          'Chăm sóc sức khỏe toàn diện',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordResetForm() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        autovalidateMode: _isFormSubmitted
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề form
            Text(
              'Đặt Lại Mật Khẩu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập mã xác nhận đã được gửi đến email của bạn và mật khẩu mới.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 25),

            // Trường mã xác nhận
            _buildTokenField(),
            const SizedBox(height: 16),

            // Trường mật khẩu mới
            _buildNewPasswordField(),
            const SizedBox(height: 16),

            // Trường xác nhận mật khẩu mới
            _buildConfirmPasswordField(),
            const SizedBox(height: 25),

            // Nút xác nhận
            _buildResetButton(),
            const SizedBox(height: 20),

            // Phần trợ giúp
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenField() {
    return TextFormField(
      controller: _tokenController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      style: TextStyle(color: Colors.grey[800], fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Mã Xác Nhận',
        hintText: 'Nhập mã xác nhận từ email',
        prefixIcon: Icon(Icons.vpn_key_outlined, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _errorColor, width: 1),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập mã xác nhận';
        }
        return null;
      },
    );
  }

  Widget _buildNewPasswordField() {
    return TextFormField(
      controller: _newPasswordController,
      textInputAction: TextInputAction.next,
      obscureText: !_isPasswordVisible,
      style: TextStyle(color: Colors.grey[800], fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Mật Khẩu Mới',
        hintText: 'Tối thiểu 6 ký tự',
        prefixIcon: Icon(Icons.lock_outline, color: _primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _errorColor, width: 1),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập mật khẩu mới';
        } else if (value.length < 6) {
          return 'Mật khẩu phải có ít nhất 6 ký tự';
        } else if (!RegExp(r'(?=.*[a-zA-Z])').hasMatch(value)) {
          return 'Mật khẩu phải có ít nhất 1 chữ cái';
        } else if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
          return 'Mật khẩu phải có ít nhất 1 số';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      textInputAction: TextInputAction.done,
      obscureText: !_isConfirmPasswordVisible,
      style: TextStyle(color: Colors.grey[800], fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Xác Nhận Mật Khẩu',
        hintText: 'Nhập lại mật khẩu mới',
        prefixIcon: Icon(Icons.lock_outline, color: _primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey.shade600,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _errorColor, width: 1),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng xác nhận mật khẩu';
        }
        if (value != _newPasswordController.text) {
          return 'Mật khẩu không khớp';
        }
        return null;
      },
      onFieldSubmitted: (_) => _resetPassword(),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: _primaryColor.withOpacity(0.4),
          disabledBackgroundColor: _primaryColor.withOpacity(0.6),
        ),
        child: _isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 2.5,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Đặt Lại Mật Khẩu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.check_circle_outline, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Center(
      child: Column(
        children: [
          // Đường kẻ với chữ
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'HOẶC',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quay lại đăng nhập
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Đã nhớ mật khẩu?',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 15,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                style: TextButton.styleFrom(
                  foregroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: const Text(
                  'Đăng nhập ngay',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),

          // Quay lại trang quên mật khẩu
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/forgot-password'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restart_alt, size: 16),
                const SizedBox(width: 4),
                Text('Yêu cầu mã mới'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 10,
      left: 10,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: () => Navigator.pushReplacementNamed(context, '/forgot-password'),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController?.dispose();
    super.dispose();
  }
}