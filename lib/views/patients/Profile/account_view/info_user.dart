import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical_storage/models/patient_profile.dart';
import 'package:medical_storage/models/user.dart';
import 'package:provider/provider.dart';
import '../../../../provider/user_provider.dart';
import '../../../../services/user_service.dart';
import 'edit_profile.dart';

class PersonalInfoPage extends StatefulWidget {
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final UserService _userService = UserService();
  final ImagePicker _picker = ImagePicker();
  User? _user;
  PatientProfile? _patientProfile;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _changeProfilePicture() async {
    try {
      if (_isUploading) return;

      setState(() {
        _isUploading = true;
      });

      // Chọn ảnh từ thư viện
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (pickedFile != null && mounted) {
        print('✅ Đã chọn ảnh: ${pickedFile.path}');

        // Hiển thị loading
        _showLoadingDialog();

        // Chuyển đổi XFile sang File
        File imageFile = File(pickedFile.path);

        try {
          // Lấy userId
          final String? userId = await _userService.getUserId();

          if (userId == null) {
            throw Exception('Không tìm thấy User ID');
          }

          // Gọi hàm upload ảnh từ UserService
          final updatedUser = await _userService.uploadImage(userId, imageFile);
          _dismissLoadingDialog();

          // Reset trạng thái upload
          if (mounted) {
            setState(() {
              _isUploading = false;
            });
          }

          if (updatedUser != null && mounted && _patientProfile != null) {
            setState(() {
              // Cập nhật đúng kiểu dữ liệu - chỉ cập nhật user trong patientProfile
              _patientProfile = _patientProfile!.copyWith(user: updatedUser);
            });

            // Hiển thị thông báo thành công
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cập nhật ảnh đại diện thành công'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (mounted) {
            // Xử lý khi upload thất bại
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Không thể cập nhật ảnh đại diện'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (uploadError) {
          // Đóng loading dialog nếu có lỗi
          _dismissLoadingDialog();

          // Reset trạng thái upload
          if (mounted) {
            setState(() {
              _isUploading = false;
            });

            // Hiển thị lỗi upload
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi upload: $uploadError'),
                backgroundColor: Colors.red,
              ),
            );
          }
          print('❌ Lỗi upload: $uploadError');
        }
      } else {
        // Nếu không chọn ảnh, reset trạng thái
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    } catch (e) {
      // Xử lý lỗi khi chọn ảnh
      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('❌ Chi tiết lỗi: $e');
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
                Text('Đang tải ảnh lên...')
              ],
            ),
          ),
        );
      },
    );
  }

  // Phương thức để đóng dialog loading an toàn
  void _dismissLoadingDialog() {
    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final String? userId = await _userService.getUserId();
      final userData = await _userService.getDataUser(userId);

      if (mounted) {
        setState(() {
          _patientProfile = userData;
          _isLoading = false;
        });

        // ✅ Thêm đoạn này để lưu vào Provider
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userData!.user);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải thông tin người dùng';
          _isLoading = false;
        });
      }
      print('❌ Lỗi tải profile: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    // Nếu đang tải
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Thông tin cá nhân'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Nếu có lỗi
    if (_errorMessage.isNotEmpty || _patientProfile == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Thông tin cá nhân'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage.isNotEmpty ? _errorMessage : 'Không có thông tin người dùng'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = '';
                  });
                  _fetchUserProfile();
                },
                child: Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Giao diện chính
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          'Thông tin cá nhân',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile avatar with change option
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _patientProfile?.user.avatar != null && _patientProfile!.user.avatar!.isNotEmpty
                          ? NetworkImage(_patientProfile!.user.avatar!)
                          : null,
                      backgroundColor: Colors.grey[200],
                      child: Stack(
                        children: [
                          if (_patientProfile?.user.avatar == null || _patientProfile!.user.avatar!.isEmpty)
                            Icon(Icons.person, size: 60, color: Colors.grey[400]),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _isUploading ? null : _changeProfilePicture,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                        onPressed: _isUploading ? null : _changeProfilePicture,
                        child: Text('Thay đổi ảnh đại diện'),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        )
                    )
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Personal information fields
              _buildInfoField('Họ và tên', _patientProfile?.user.fullName ?? '', false),
              _buildDivider(),
              _buildInfoField('Email', _patientProfile?.user.email ?? '', false),
              _buildDivider(),
              _buildInfoField('Địa chỉ', _patientProfile?.user.address ?? '', false),
              _buildDivider(),
              _buildInfoField('Nhóm máu', _patientProfile?.bloodType?.toString() ?? '', false),
              _buildDivider(),
              _buildInfoField('Dị ứng', _patientProfile?.allergies ?? '', false),
              _buildDivider(),
              _buildInfoField('Lịch sử bệnh', _patientProfile?.medicalHistory ?? '', false),
              _buildDivider(),

              SizedBox(height: 40),

              // Edit information button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()
                      ),
                    );

                    // Nếu có dữ liệu trả về, cập nhật lại profile
                    if (result == true) {
                      _fetchUserProfile();
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.blue.withOpacity(0.7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Chỉnh sửa thông tin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Giữ nguyên các phương thức _buildInfoField và _buildDivider như ban đầu
  Widget _buildInfoField(String label, String value, bool isAddable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              Text(
                value.isEmpty ? '' : value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              isAddable
                  ? Text(
                'Thêm thông tin',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }
}