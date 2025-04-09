import 'package:flutter/material.dart';
import 'package:medical_storage/models/patient_profile.dart';
import 'package:medical_storage/services/auth_service.dart';
import 'package:medical_storage/services/user_service.dart';
import 'package:medical_storage/models/user.dart';
import 'package:medical_storage/views/patients/Profile/account_view/deposit.dart';
import 'package:medical_storage/widgets/HomeWidget/bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  PatientProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      final String? userId = await _userService.getUserId();
      final userProfile = await _userService.getDataUser(userId);
      setState(() {
        _userProfile = userProfile;
        _isLoading = false;
      });
    } catch (e) {
      _handleProfileError(e);
    }
  }

  void _handleProfileError(dynamic error) {
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Không thể tải thông tin người dùng: $error'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildProfileHeader() {
    if (_userProfile == null) return const SizedBox.shrink();

    final avatarUrl = _userProfile!.user.avatar;
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          child: avatarUrl != null && avatarUrl.isNotEmpty
              ? ClipOval(
            child: Image.network(
              avatarUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Lỗi tải ảnh: $error');
                return Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator(
                  strokeWidth: 2,
                );
              },
            ),
          )
              : Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _userProfile!.user.fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _userProfile!.user.email,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildOrderStatusIcon(
            Icons.pending,
            'Đang xử lý',
                () => print("Pending icon tapped"),
          ),
          _buildOrderStatusIcon(
            Icons.local_shipping,
            'Đang Giao',
                () => print("Delivering icon tapped"),
          ),
          _buildOrderStatusIcon(
            Icons.check_circle,
            'Đã Giao',
                () => print("Delivered icon tapped"),
          ),
          _buildOrderStatusIcon(
            Icons.cached,
            'Đổi/Trả',
                () => print("Exchange/Return icon tapped"),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAccountMenuItem(
            Icons.person,
            'Thông tin cá nhân',
                () => Navigator.pushNamed(context, '/info-user'),
          ),
          _buildAccountMenuItem(
            Icons.money,
            'Nạp tiền',
                () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DepositPage()),
            ),
          ),
          _buildAccountMenuItem(
            Icons.medication,
            'Đơn của tôi',
                () => print("My Orders tapped"),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountMenuItem(
      IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () => _showLogoutDialog(context),
      icon: const Icon(Icons.logout),
      label: const Text('Đăng xuất'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _authService.logout(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusIcon(
      IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: Colors.blueAccent),
          onPressed: onPressed,
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Tài Khoản'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Không thể tải thông tin người dùng'),
            ElevatedButton(
              onPressed: _fetchUserProfile,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildSectionTitle('Trạng thái đơn hàng'),
            _buildOrderStatusSection(),
            const SizedBox(height: 20),
            _buildSectionTitle('Tài Khoản'),
            _buildAccountSection(),
            const SizedBox(height: 20),
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 3,
        bottomNavType: BottomNavigationBarType.fixed,
        onTap: (index) {
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
          }
        },
        onNavTypeChanged: (_) {},
      ),
    );
  }
}