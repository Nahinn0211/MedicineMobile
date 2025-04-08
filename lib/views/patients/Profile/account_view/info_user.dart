import 'package:flutter/material.dart';
import '../../../../models/user.dart';
import '../../../../services/user_service.dart';
import 'edit_profile.dart';

class PersonalInfoPage extends StatefulWidget {
  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userData = await _userService.getUserProfile();

      setState(() {
        _user = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải thông tin người dùng';
        _isLoading = false;
      });
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
    if (_errorMessage.isNotEmpty || _user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Thông tin cá nhân'),
        ),
        body: Center(
          child: Text(_errorMessage.isNotEmpty ? _errorMessage : 'Không có thông tin người dùng'),
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
                      backgroundImage: NetworkImage(
                          _user?.avatar ?? 'https://via.placeholder.com/150'
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            bottom: 0,
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
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextButton(
                        onPressed: () {
                          // TODO: Implement avatar change
                        },
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
              _buildInfoField('Họ và tên', _user?.fullName ?? '', false),
              _buildDivider(),
              _buildInfoField('Email', _user?.email ?? '', false),
              _buildDivider(),
              _buildInfoField('Số điện thoại', _user?.phone ?? '', false),
              _buildDivider(),

              SizedBox(height: 40),

              // Edit information button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()
                      ),
                    );
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