import 'package:flutter/material.dart';
import 'package:medical_storage/services/auth_service.dart';
import '../../views/patients/Profile/profile_page.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final BottomNavigationBarType bottomNavType;
  final ValueChanged<int> onTap;
  final ValueChanged<BottomNavigationBarType> onNavTypeChanged;
  final AuthService _authService = AuthService();

   CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.bottomNavType,
    required this.onTap,
    required this.onNavTypeChanged,
  }) : super(key: key);

  // Hàm hiển thị dialog yêu cầu đăng nhập
  void _showLoginPromptDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yêu cầu Đăng nhập'),
          content: Text('Bạn cần đăng nhập để truy cập trang cá nhân. Bạn có muốn đăng nhập ngay bây giờ?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
            ),
            ElevatedButton(
              child: Text('Đăng nhập'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Đóng dialog và chuyển đến trang đăng nhập
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm kiểm tra và điều hướng đến trang Profile
  Future<void> _navigateToProfile(BuildContext context) async {
    bool isLoggedIn = await _authService.isLoggedIn();

    if (isLoggedIn) {
      // Nếu đã đăng nhập, chuyển đến trang Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(),
        ),
      );
    } else {
      // Nếu chưa đăng nhập, hiển thị dialog
      _showLoginPromptDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BottomNavigationBar(
          currentIndex: selectedIndex,
          selectedItemColor: const Color(0xff2196f3),
          unselectedItemColor: const Color(0xff2196f3),
          type: bottomNavType,
          onTap: (index) {
            if (index == 0) {
              // Điều hướng tới trang Home
              Navigator.pushReplacementNamed(context, '/home');
            } else if (index == 1) {
              // Điều hướng tới trang Services
              Navigator.pushNamed(context, '/services');
            } else if (index == 2) {
              // Điều hướng tới trang Cart
              Navigator.pushNamed(context, '/cart');
            } else if (index == 3) {
              // Kiểm tra và điều hướng tới trang Profile
              _navigateToProfile(context);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.support_agent),
              activeIcon: Icon(Icons.support_agent_rounded),
              label: 'Dịch vụ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Giỏ hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Tài khoản',
            ),
          ],
        ),
      ],
    );
  }
}