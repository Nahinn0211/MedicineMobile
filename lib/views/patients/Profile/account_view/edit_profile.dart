import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical_storage/models/blood_type.dart';
import '../../../../models/patient_profile.dart';
import '../../../../models/user.dart';
import '../../../../services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  final PatientProfile? initialProfile;

  const EditProfilePage({Key? key, this.initialProfile}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  PatientProfile? _patientProfile;
  bool _isLoading = true;
  String? _selectedBloodType;

  // Controller cho thông tin User
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  // Controller cho thông tin PatientProfile
  late TextEditingController _allergiesController;
  late TextEditingController _medicalHistoryController;

  // Danh sách nhóm máu
  final List<String> _bloodTypeDisplayValues = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  final Map<String, BloodType> _bloodTypeMap = {
    'A+': BloodType.A_POSITIVE,
    'A-': BloodType.A_NEGATIVE,
    'B+': BloodType.B_POSITIVE,
    'B-': BloodType.B_NEGATIVE,
    'AB+': BloodType.AB_POSITIVE,
    'AB-': BloodType.AB_NEGATIVE,
    'O+': BloodType.O_POSITIVE,
    'O-': BloodType.O_NEGATIVE,
  };

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final String? userId = await _userService.getUserId();
      final userData = await _userService.getDataUser(userId);

      if (mounted) {
        setState(() {
          _patientProfile = userData;
          _isLoading = false;

          // Khởi tạo các controller với dữ liệu từ API
          _fullNameController = TextEditingController(
              text: _patientProfile?.user.fullName ?? '');
          _phoneController = TextEditingController(
              text: _patientProfile?.user.phone ?? '');
          _emailController = TextEditingController(
              text: _patientProfile?.user.email ?? '');
          _addressController = TextEditingController(
              text: _patientProfile?.user.address ?? '');
          _allergiesController = TextEditingController(
              text: _patientProfile?.allergies ?? '');
          _medicalHistoryController = TextEditingController(
              text: _patientProfile?.medicalHistory ?? '');

          if (_patientProfile?.bloodType != null) {
            _selectedBloodType = _patientProfile!.bloodType!.toDisplayString();
          } else {
            _selectedBloodType = 'A+'; // Giá trị mặc định nếu null
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Khởi tạo controllers mặc định trong trường hợp lỗi
          _fullNameController = TextEditingController();
          _phoneController = TextEditingController();
          _addressController = TextEditingController();
          _emailController = TextEditingController();
          _allergiesController = TextEditingController();
          _medicalHistoryController = TextEditingController();
          _selectedBloodType = null;
        });
      }
      print('❌ Lỗi tải profile: $e');
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _allergiesController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Hiển thị loading
        _showLoadingDialog();

        // Tạo đối tượng User với thông tin cập nhật
        User updatedUser = User(
          id: _patientProfile?.user.id,
          fullName: _fullNameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          address: _addressController.text,
          // Bắt buộc cần trường password
          password: '',
        );

        // Cập nhật thông tin User
        final updatedUserResult = await _userService.updateUserProfile(updatedUser);

        if (updatedUserResult != null) {
          // Tạo đối tượng PatientProfile mới với thông tin cập nhật
          final updatedPatientProfile = _patientProfile!.copyWith(
            user: updatedUserResult,
            bloodType: _bloodTypeMap[_selectedBloodType],
            allergies: _allergiesController.text,
            medicalHistory: _medicalHistoryController.text,
          );

          // Cập nhật thông tin PatientProfile
          final result = await _userService.updatePatientProfile(updatedPatientProfile);

          _dismissLoadingDialog();

          if (result != null) {
            // Thông báo cập nhật thành công
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cập nhật thông tin thành công'),
                backgroundColor: Colors.green,
              ),
            );

            // Quay lại trang trước với kết quả thành công
            Navigator.pop(context, true);
          } else {
            // Thông báo lỗi
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cập nhật thông tin y tế thất bại'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          _dismissLoadingDialog();
          // Thông báo lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật thông tin cá nhân thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        _dismissLoadingDialog();
        // Xử lý lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
        print('❌ Lỗi cập nhật: $e');
      }
    }
  }

  void _showLoadingDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Ngăn đóng khi nhấn nút back
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang cập nhật thông tin...')
              ],
            ),
          ),
        );
      },
    );
  }

  void _dismissLoadingDialog() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị loading khi đang tải dữ liệu
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Chỉnh sửa thông tin'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần thông tin cá nhân
                _buildSectionTitle('Thông tin cá nhân'),
                SizedBox(height: 16),
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
                    // Số điện thoại có thể trống
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
                    // Thêm validate email format nếu cần
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'Địa chỉ',
                  keyboardType: TextInputType.streetAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa chỉ';
                    }
                    // Thêm validate email format nếu cần
                    return null;
                  },
                ),

                SizedBox(height: 32),

                // Phần thông tin y tế
                _buildSectionTitle('Thông tin y tế'),
                SizedBox(height: 16),

                // Dropdown chọn nhóm máu
                _buildBloodTypeDropdown(),
                SizedBox(height: 16),

                _buildTextField(
                  controller: _allergiesController,
                  label: 'Dị ứng',
                  hintText: 'Liệt kê các dị ứng nếu có',
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _medicalHistoryController,
                  label: 'Lịch sử bệnh',
                  hintText: 'Mô tả lịch sử bệnh của bạn',
                  maxLines: 5,
                ),

                SizedBox(height: 32),

                // Nút cập nhật
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text(
                    'Cập nhật thông tin',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBloodTypeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Nhóm máu',
            border: InputBorder.none,
          ),
          value: _selectedBloodType,
          items: _bloodTypeDisplayValues.map((String bloodType) { // Đã sửa _bloodTypes thành _bloodTypeDisplayValues
            return DropdownMenuItem<String>(
              value: bloodType,
              child: Text(bloodType),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedBloodType = newValue;
            });
          },
          hint: Text('Chọn nhóm máu'),
          isExpanded: true,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade800,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    );
  }
}