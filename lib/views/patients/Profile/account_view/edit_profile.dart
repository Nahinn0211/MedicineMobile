import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/user.dart';
import '../../../../services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  final User? initialUser;

  const EditProfilePage({Key? key, this.initialUser}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;


  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller với giá trị ban đầu
    _fullNameController = TextEditingController(
        text: widget.initialUser?.fullName ?? '');
    _phoneController = TextEditingController(
        text: widget.initialUser?.phone ?? '');
    _emailController = TextEditingController(
        text: widget.initialUser?.email ?? '');

  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();

    super.dispose();
  }


  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Tạo đối tượng User với thông tin mới
        final updatedUser = User(
          fullName: _fullNameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          password: '',
        );

        // Gọi phương thức cập nhật từ UserService
        final result = await _userService.updateUserProfile(updatedUser);
        if (result != null) {
          // Thông báo cập nhật thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cập nhật thông tin thành công')),
          );

          // Quay lại trang trước
          Navigator.pop(context, result);
        } else {
          // Thông báo lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cập nhật thông tin thất bại')),
          );
        }
      } catch (e) {
        // Xử lý lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa thông tin'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Họ và tên',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Số điện thoại',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text('Cập nhật'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}