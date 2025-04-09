import 'package:flutter/material.dart';
import 'package:medical_storage/services/auth_service.dart'; // Import AuthService
import 'package:medical_storage/views/menu_views/disease_views.dart';
import 'package:medical_storage/views/menu_views/doctor_page.dart';
import 'package:medical_storage/views/menu_views/health_supplements_page.dart';
import 'package:medical_storage/views/menu_views/medicin_page.dart';

class AppBarMenu extends StatefulWidget {
  @override
  _AppBarMenuState createState() => _AppBarMenuState();
}

class _AppBarMenuState extends State<AppBarMenu> {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool isLoggedIn = await _authService.isLoggedIn();
    print('Trạng thái đăng nhập : $isLoggedIn');
    if(mounted) {
      setState(() {
        _isLoggedIn = isLoggedIn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THAVP Medicine',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 20),

                // Chỉ hiển thị nút đăng nhập/đăng ký khi chưa đăng nhập
                if (!_isLoggedIn)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blueAccent,
                          backgroundColor: Colors.white,
                        ),
                        child: Text('Đăng nhập'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blueAccent,
                          backgroundColor: Colors.white,
                        ),
                        child: Text('Đăng ký'),
                      ),
                    ],
                  ),

                // Hiển thị thông tin người dùng khi đã đăng nhập
                if (_isLoggedIn)
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.blueAccent),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Tài khoản của tôi',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),

                  ),
                // TextButton(
                //   child: Text('Đăng xuất'),
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //     AuthService().logout(context);
                //   },
                //   style: TextButton.styleFrom(
                //     foregroundColor: Colors.white,
                //     backgroundColor: Colors.redAccent,
                //   ),
                // ),
              ],
            ),
          ),

          // Các mục menu khác giữ nguyên
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Thông báo'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.medical_services),
            title: Text('Thuốc'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>MedicineListPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.medication_liquid),
            title: Text('Thực phẩm chức năng'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>HealthSupplementPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.personal_injury),
            title: Text('Chăm sóc cá nhân'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.sick),
            title: Text('Bệnh'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>DiseasePage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.account_box),
            title: Text('Bác sĩ'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorPage()));
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Hotline tư vấn: 1800 6928'),
            onTap: () {},
          ),

        ],
      ),
    );
  }


}