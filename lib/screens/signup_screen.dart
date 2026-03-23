import 'package:badilni_v1/providers/my_auth_provider.dart';
import 'package:badilni_v1/screens/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false; // متغير حالة لمؤشر التحميل

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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 8) {
      return 'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل';
    }
    final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'يجب أن تحتوي كلمة المرور على أحرف كبيرة وصغيرة ورموز';
    }
    return null;
  }

  // بعد التعديل للتناسب مع صيغة دولية +966 أو 966
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الجوال';
    }
    final phoneRegex = RegExp(r'^(?:\+966|966)5\d{8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'يرجى إدخال رقم جوال بصيغة دولية (مثال: +966550037776)';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال اسم المستخدم';
    }
    if (value.length < 3 || value.length > 20) {
      return 'يجب أن يكون طول اسم المستخدم بين 3 و 20 حرفًا';
    }

    final arabicRegex = RegExp(r'[\u0621-\u064A\u0660-\u0669]');
    final englishRegex = RegExp(r'[a-zA-Z0-9]');

    if (arabicRegex.hasMatch(value) && englishRegex.hasMatch(value)) {
      return 'يرجى اختيار لغة واحدة فقط (عربية أو إنجليزية)';
    }

    final usernameRegex =
    RegExp(r'^[a-zA-Z0-9._\u0621-\u064A\u0660-\u0669]{3,20}$');
    if (!usernameRegex.hasMatch(value)) {
      return 'يمكنك استخدام الأحرف والأرقام مع "_" و "." فقط';
    }

    if (value.startsWith('.') ||
        value.startsWith('_') ||
        value.endsWith('.') ||
        value.endsWith('_')) {
      return 'الاسم لا يجب أن يبدأ أو ينتهي بـ "_" أو "."';
    }

    if (value.contains('..') ||
        value.contains('__') ||
        value.contains('._') ||
        value.contains('_.')) {
      return 'يرجى تجنب الرموز المتكررة مثل ".." أو "__"';
    }

    if (value.startsWith('Ad5')) {
      return 'اسم مستخدم غير صالح"';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // يتيح إعادة ضبط الواجهة عند ظهور لوحة المفاتيح
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: "إنشاء حساب",
        ),
        body: Stack(
          children: [
            // الصورة في الأعلى
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'assets/img/SignOL.jpeg',
                width: 400,
                height: 200,
              ),
            ),
            // النموذج
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              // إضافة bottom: 0 لجعل SingleChildScrollView يشغل باقي المساحة
              bottom: 0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(minHeight: 60),
                          child: CustomTextField(
                            controller: _usernameController,
                            hintText: 'اسم المستخدم',
                            validator: _validateUsername,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          constraints: const BoxConstraints(minHeight: 60),
                          child: CustomTextField(
                            controller: _phoneController,
                            hintText: 'رقم الهاتف مبتدأً بـ : +9665 أو 9665',
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: 'تسجيل',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              final authProvider = Provider.of<MyAuthProvider>(
                                context,
                                listen: false,
                              );
                              String? error = await authProvider.signUp(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                                _phoneController.text.trim(),
                                _usernameController.text.trim(),
                              );
                              setState(() {
                                _isLoading = false;
                              });
                              if (error == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "تم إرسال رابط التحقق إلى بريدك الإلكتروني",
                                    ),
                                  ),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AuthWrapper(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error)),
                                );
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'لديك حساب بالفعل؟ تسجيل الدخول',
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // مؤشر التحميل الذي يظهر فوق باقي المحتويات أثناء عملية التسجيل
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
