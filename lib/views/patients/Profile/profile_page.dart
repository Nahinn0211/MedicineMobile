import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:medical_storage/services/auth_service.dart';
import '../../../models/user.dart';
import '../../../widgets/HomeWidget/bottom_bar.dart';
import 'account_view/address.dart';
import 'account_view/payment.dart';
import 'doncuatoi/order_page.dart';
import 'package:medical_storage/services/user_service.dart';



class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;
  BottomNavigationBarType _bottomNavType = BottomNavigationBarType.fixed;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _userProfile;

  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      print('Trạng thái đăng nhập: $isLoggedIn');

      if (!isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      final userProfile = await _userService.getUserProfile();
      print('Thông tin người dùng: $userProfile');

      setState(() {
        _userProfile = userProfile;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi chi tiết: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải thông tin người dùng';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Điều hướng theo index được chọn
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/services');
        break;
      case 2:
        Navigator.pushNamed(context, '/cart');
        break;
      case 3:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Không thể tải thông tin người dùng'),
              ElevatedButton(
                onPressed: _fetchUserProfile,
                child: Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    final username = _userProfile!.fullName;
    final email = _userProfile!.email;
    final avatarUrl = _userProfile!.avatar??  'https://via.placeholder.com/150';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(avatarUrl),
              child: avatarUrl == 'https://via.placeholder.com/150'
                  ? Icon(Icons.person, size: 30)
                  : null,
            ),
            SizedBox(width: 10),
            Text(
              username,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ảnh đại diện người dùng
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              SizedBox(height: 20),

              // Tên người dùng
              Text(
                username,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // Email người dùng
              Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              SizedBox(height: 20),
              // (Phần còn lại của mã giữ nguyên như bản gốc)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đơn của tôi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (
                            context) => OrderPage()));
                      },
                      child: Text('Xem tất cả'),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildOrderStatusIcon(
                              Icons.pending,
                              'Đang xử lý',
                                  () {
                                print("Pending icon tapped");
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildOrderStatusIcon(
                              Icons.local_shipping,
                              'Đang Giao',
                                  () {
                                print("Delivering icon tapped");
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildOrderStatusIcon(
                              Icons.check_circle,
                              'Đã Giao',
                                  () {
                                print("Delivered icon tapped");
                              },
                            ),
                          ),
                          Expanded(
                            child: _buildOrderStatusIcon(
                              Icons.cached,
                              'Đổi/Trả',
                                  () {
                                print("Exchange/Return icon tapped");
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tài Khoản',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/info-user');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 30, color: Colors.blueAccent),
                            SizedBox(width: 16),
                            Text(
                              'Thông tin cá nhân',
                              style: TextStyle(fontSize: 16),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddressManagementPage()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, size: 30, color: Colors.blueAccent),
                            SizedBox(width: 16),
                            Text(
                              'Địa chỉ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AccountViewPaymentMethodPage()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.credit_card, size: 30, color: Colors.blueAccent),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Phương thức thanh toán',
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    InkWell(
                      onTap: () {
                        print("My Orders tapped");
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.medication, size: 30, color: Colors.blueAccent),
                            SizedBox(width: 16),
                            Text(
                              'Đơn của tôi',
                              style: TextStyle(fontSize: 16),
                            ),
                            Spacer(),
                            Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Nút Đăng xuất
              ElevatedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                icon: Icon(Icons.logout),
                label: Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        bottomNavType: _bottomNavType,
        onTap: _onItemTapped,
        onNavTypeChanged: (newType) {
          setState(() {
            _bottomNavType = newType;
          });
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Đăng xuất'),
          content: Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Đăng xuất'),
              onPressed: () {
                Navigator.of(context).pop();
                AuthService().logout(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderStatusIcon(IconData icon, String label,
      VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: Colors.blueAccent),
          onPressed: onPressed, // Xử lý sự kiện nhấn vào icon
        ),
        SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildTitleIcon(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: Colors.blueAccent),
          onPressed: onPressed, // Xử lý sự kiện nhấn vào icon
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}