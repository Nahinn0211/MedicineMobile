import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical_storage/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isFormSubmitted = false;

  // Thêm service
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

  Future<void> _sendResetLink() async {
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
        // Gọi service để gửi yêu cầu quên mật khẩu
        final result = await _authService.forgotPassword(_emailController.text.trim(), context);

        // Kiểm tra kết quả
        if (result.success) {
          // Không cần hiển thị thông báo vì đã được xử lý trong hàm forgotPassword
          // Không cần chuyển hướng vì đã được xử lý trong hàm forgotPassword
        } else {
          // Hiển thị thông báo lỗi nếu chưa được xử lý trong hàm forgotPassword
          if (mounted && result.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.errorMessage!,
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
        }
      } catch (e) {
        // Xử lý lỗi không mong đợi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Không thể gửi yêu cầu: ${e.toString()}',
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
              'Quên Mật Khẩu?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập địa chỉ email của bạn và chúng tôi sẽ gửi một mã xác nhận để đặt lại mật khẩu của bạn.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 25),

            // Trường email
            _buildEmailField(),
            const SizedBox(height: 25),

            // Nút gửi
            _buildSendButton(),
            const SizedBox(height: 20),

            // Phần trợ giúp
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.grey[800], fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Nhập email đã đăng ký',
        prefixIcon: Icon(Icons.email_outlined, color: _primaryColor),
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
          return 'Vui lòng nhập địa chỉ email của bạn';
        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Vui lòng nhập địa chỉ email hợp lệ';
        }
        return null;
      },
      onFieldSubmitted: (_) => _sendResetLink(),
      autocorrect: false,
      autofillHints: const [AutofillHints.email],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendResetLink,
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
              'Gửi Mã Xác Nhận',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.send_rounded, size: 18),
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

          // Liên kết trợ giúp
          TextButton(
            onPressed: () {
              // Hiển thị hộp thoại trợ giúp hoặc điều hướng đến trang trợ giúp
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Liên hệ hỗ trợ kỹ thuật để được giúp đỡ'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline, size: 16),
                const SizedBox(width: 4),
                Text('Cần hỗ trợ?'),
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
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
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
    _emailController.dispose();
    _animationController?.dispose();
    super.dispose();
  }
}