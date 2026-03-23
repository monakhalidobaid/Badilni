import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/my_auth_provider.dart';
import '../style/styled_text.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  Future<void> _checkVerification() async {
    final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
    bool verified = await authProvider.checkEmailVerified();
    setState(() {
      _isVerified = verified;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyAuthProvider>(context).currentUser;

    if (user != null) {
      if (_isVerified) {
        return const HomeScreen();
      } else {
        return  PopScope(
            canPop: false, // تحكم في السماح بالرجوع أم لا
            child:


          Scaffold(
            backgroundColor: Colors.white,

            body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "يرجى التحقق من بريدك الإلكتروني",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(280, 25), // حجم الزر
                    backgroundColor: AppTheme.primaryColor,
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _checkVerification,
                  child: const BodySmall("تحقق مجددًا"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(280, 25), // حجم الزر
                    backgroundColor: AppTheme.primaryColor,
                    textStyle: const TextStyle(fontSize: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Provider.of<MyAuthProvider>(context, listen: false).signOut();
                  },
                  child: const BodySmall("تسجيل الخروج"),
                ),
              ],
            ),
          ),
        ));
      }
    } else {
      return const WelcomeScreen();
    }
  }
}
