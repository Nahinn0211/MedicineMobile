
import 'package:flutter/material.dart';
import 'package:medical_storage/services/cart_service.dart';
import 'package:medical_storage/services/user_service.dart';
import 'package:medical_storage/views/auth/forgot_password.dart';
import 'package:medical_storage/views/auth/reset_password.dart';
import 'package:medical_storage/views/auth/verify_code.dart';
import 'package:medical_storage/views/patients/Profile/account_view/info_user.dart';
import 'package:medical_storage/views/patients/Profile/lichtuvan/consultation_screen.dart';
import 'package:medical_storage/views/patients/Profile/profile_page.dart';
import 'package:medical_storage/views/patients/service_page.dart';
import 'package:medical_storage/widgets/auth_guard.dart';
import 'package:provider/provider.dart';
import 'views/auth/login_page.dart';
import 'views/patients/home_page.dart';
import 'views/auth/register_page.dart';
import 'views/patients/cart_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        Provider<UserService>(create: (_)=> UserService()),
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: MedicalStoreApp(),  // Dùng MedicalStoreApp duy nhất
    ),
  );
}

class MedicalStoreApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'THAVP Medicine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/forgotpassword': (context) => ForgotPasswordPage(),
        '/verifycode': (context) => VerifyCodePage(),
        '/resetpassword': (context) => ResetPasswordPage(),
        '/home': (context) => HomePage(),
        '/cart': (context) => CartPage(),
        '/profile' : (context) => AuthGuard(child: ProfilePage()),
        // '/address':(context)=> AddressManagementPage(),
        '/info-user' : (context) => PersonalInfoPage(),
        '/services' : (context) => ServicePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/consultation') {
          // Cast the arguments to the correct type
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ConsultationScreen(args: args),
          );
        }
        return null;
      },
    );
  }
}
