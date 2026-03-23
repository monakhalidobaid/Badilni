import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/my_auth_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import 'admin_home_screen.dart';

class AdminLoginScreen extends StatelessWidget {
   AdminLoginScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// عرض نافذة إعادة تعيين كلمة المرور
  void _showResetPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إعادة تعيين كلمة المرور'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'أدخل بريدك الإلكتروني',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';
                }
                final emailRegex =
                RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'يرجى إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: emailController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال رابط إعادة التعيين إلى بريدك')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('إرسال'),
            ),
          ],
        );
      },
    );
  }

  /// التحقق من صحة البريد الإلكتروني
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    final emailRegex =
    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  /// التحقق من صحة كلمة المرور
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 8) {
      return 'يجب أن تكون كلمة المرور مكونة من 8 أحرف ';
    }
    return null;
  }

//login

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
      backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: " تسجيل الدخول كمسؤول",
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/img/admin.png',
                  width: 400,
                  height: 230,
                ),
                const SizedBox(height: 32),
                Container(
                  constraints: const BoxConstraints(minHeight: 60),

                  child: CustomTextField(
                    controller: _emailController,
                    hintText: 'البريد الإلكتروني',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(minHeight: 60),

                  child: CustomTextField(
                    controller: _passwordController,
                    hintText: 'كلمة المرور',
                    isPassword: true,
                    validator: _validatePassword,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showResetPasswordDialog(context);
                    },
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                          color: Colors.blueAccent, fontSize: 13),
                    ),
                  ),
                ),
                PrimaryButton(
                  text: 'دخول',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();

                      // استدعاء تسجيل الدخول من MyAuthProvider
                      String? result = await Provider.of<MyAuthProvider>(
                          context, listen: false).adminSignIn(email, password);

                      if (result == null) {
                        // نجاح تسجيل الدخول، الانتقال إلى الصفحة الرئيسية
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AdminHomeScreen()),
                        );
                      } else {
                        // عرض رسالة خطأ عند الفشل
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                      }
                    }
                  },
                ),



                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
