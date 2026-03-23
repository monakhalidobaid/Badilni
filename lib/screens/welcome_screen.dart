import 'package:badilni_v1/providers/my_auth_provider.dart';
import 'package:badilni_v1/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_appbar.dart';
import 'admin/admin_login_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import '../widgets/primary_button.dart';
//
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);

    if (authProvider.currentUser != null) {
      // استخدام currentUser بدلاً من user
      return const HomeScreen();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          // نص ترحيبي في أعلى الشاشة
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 370,
            child: Center(
              child: Image.asset('assets/img/balini1.png', width: 300, height: 300)
              ,
            ),
          ),


          // زر "إنشاء حساب" في منتصف الشاشة
          Positioned(
            bottom: 280,
            left: MediaQuery.of(context).size.width / 2 - 140, // لتوسيط الزر الذي عرضه 260
            child: PrimaryButton(
              text: 'إنشاء حساب',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
            ),
          ),
          // زر "تسجيل الدخول" أسفل الزر الأول
          Positioned(
            bottom: 220,
            left: MediaQuery.of(context).size.width / 2 - 140,
            child: PrimaryButton(
              text: 'تسجيل الدخول',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ),
          // زر "تسجيل الدخول كمسؤول" في أسفل الشاشة
          Positioned(
            bottom: 161,
            left: MediaQuery.of(context).size.width / 2 - 140,
            child: PrimaryButton(
              text: 'تسجيل الدخول كمسؤول',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminLoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );



  }
}
