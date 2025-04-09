import 'package:flutter/material.dart';
import 'package:medical_storage/services/auth_service.dart';
import 'package:medical_storage/views/menu_views/disease_views.dart';
import 'package:medical_storage/views/menu_views/doctor_page.dart';
import 'package:medical_storage/views/menu_views/health_supplements_page.dart';
import 'package:medical_storage/views/menu_views/medicin_page.dart';

class AppBarMenu extends StatefulWidget {
  const AppBarMenu({Key? key}) : super(key: key);

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
    final isLoggedIn = await _authService.isLoggedIn();
    debugPrint('Trạng thái đăng nhập: $isLoggedIn');
    if (mounted) {
      setState(() => _isLoggedIn = isLoggedIn);
    }
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(color: Colors.blueAccent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THAVP Medicine',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 20),
          _buildAuthSection(),
        ],
      ),
    );
  }

  Widget _buildAuthSection() {
    return _isLoggedIn
        ? _buildLoggedInView()
        : _buildLoginRegisterButtons();
  }

  Widget _buildLoginRegisterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAuthButton('Đăng nhập', '/login'),
        _buildAuthButton('Đăng ký', '/register'),
      ],
    );
  }

  Widget _buildAuthButton(String text, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        backgroundColor: Colors.white,
      ),
      child: Text(text),
    );
  }

  Widget _buildLoggedInView() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/profile'),
      child: Row(
        children: const [
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
    );
  }

  List<Widget> _buildMenuItems() {
    return [
      _buildMenuItem(
        icon: Icons.medical_services,
        title: 'Thuốc',
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MedicineListPage())
        ),
      ),
      _buildMenuItem(
        icon: Icons.medication_liquid,
        title: 'Thực phẩm chức năng',
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HealthSupplementPage())
        ),
      ),
      _buildMenuItem(
        icon: Icons.sick,
        title: 'Bệnh',
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiseasePage())
        ),
      ),
      _buildMenuItem(
        icon: Icons.account_box,
        title: 'Bác sĩ',
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoctorPage())
        ),
      ),
    ];
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          ..._buildMenuItems(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Thông báo'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Hotline tư vấn: 1800 6928'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}