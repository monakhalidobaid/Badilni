import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:badilni_v1/providers/my_auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart%20' as sup;
import '../widgets/custom_appbar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'signup_screen.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {




  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false; // متغير الحالة لمؤشر التحميل

  /// عرض نافذة إعادة تعيين كلمة المرور
  void _showResetPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('إعادة تعيين كلمة المرور',style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء',style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),),
                ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: emailController.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                              Text('تم إرسال رابط إعادة التعيين إلى بريدك')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('خطأ: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: const Text('إرسال',style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),),
                ),
              ],
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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final authProvider =
      Provider.of<MyAuthProvider>(context, listen: false);
      String? error = await authProvider.signIn(
          _emailController.text.trim(), _passwordController.text.trim());
      setState(() {
        _isLoading = false;
      });
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      } else {
        User? user = authProvider.currentUser;
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }

    }
  }
  Future<String> _getImageUrl() async {
    final client = sup.Supabase.instance.client;
    // هنا 'images' هو اسم الـ bucket و 'logologin.jpg' هو مسار الصورة داخل الـ bucket.
    final imageUrl = client.storage.from('image').getPublicUrl('bookii.png');
    return imageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: "تسجيل الدخول",
        ),
        // نلف محتوى الشاشة بـ Stack لإضافة مؤشر التحميل فوق باقي المحتويات
        body: Stack(
          children: [
            // التفاف محتوى الشاشة بـ SingleChildScrollView مع ConstrainedBox للحفاظ على مظهر التصميم
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Stack(
                  children: [
                    // استخدام FutureBuilder لجلب الصورة من Supabase وعرضها عبر Image.network
                  Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'assets/img/SignOL.jpeg',
                    width: 400,
                    height: 200,
                  ),
                ),
                    Positioned(
                      top: 210, // تحديد المسافة من الأعلى بحيث تكون بين الصورة والفورم
                      left: 160,
                      right: 0,
                      child: Center(
                        child: Text(
                          'مرحباً بك من جديد',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    // الفورم تحت الصورة
                    Positioned(
                      top: 250, // رفع الفورم للأعلى قليلاً
                      left: 0,
                      right: 0,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // لفّ حقل البريد الإلكتروني في Container بارتفاع مرن
                                Container(
                                  constraints:
                                  const BoxConstraints(minHeight: 60),
                                  child: CustomTextField(
                                    controller: _emailController,
                                    hintText: 'البريد الإلكتروني',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: _validateEmail,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // لفّ حقل كلمة المرور في Container بارتفاع مرن
                                Container(
                                  constraints:
                                  const BoxConstraints(minHeight: 60),
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
                                          color: Colors.blueAccent,
                                          fontSize: 13),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                PrimaryButton(
                                  text: 'دخول',
                                  onPressed: _login,
                                ),
                                const SizedBox(height: 1),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                            const SignupScreen()),
                                      );
                                    },
                                    child: const Text(
                                      'ليس لديك حساب؟ إنشاء حساب',
                                      style:
                                      TextStyle(color: Colors.blueAccent),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // مؤشر التحميل الذي يظهر في منتصف الشاشة عند تسجيل الدخول
            if (_isLoading)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
