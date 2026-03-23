import 'package:badilni_v1/style/styled_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_ebook_screen.dart';
import 'package:badilni_v1/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/my_auth_provider.dart';
import 'manage_user_account_screen.dart';
import 'manage_books_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  bool _isLoading = true; // تحديد متغير الرفع

  @override
  void initState() {
    super.initState();
    // محاكاة تحميل البيانات (يمكنك إضافة كود حقيقي لتحميل البيانات هنا)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false; // بعد الانتهاء من التحميل
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // منع العودة إلى الوراء
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false, // إخفاء زر الرجوع
          actions: [
            IconButton(
              icon: const Icon(Icons.logout), // أيقونة تسجيل الخروج
              onPressed: () {
                Provider.of<MyAuthProvider>(context, listen: false).signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      (route) => false,
                );
              },
            ),
          ],
          title: const StyledText("لوحة التحكم "),
          centerTitle: true,
          backgroundColor: const Color(0xAD46CCBD), // لون خلفية شريط العنوان
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
              children: [
                // الصورة في الأعلى مع تحديد موقعها بدقة
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/img/analysis.png', // تأكد من صحة المسار في pubspec.yaml
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                // باقي المحتوى (الأزرار) يبدأ من تحت الصورة
                Positioned(
                  top: 400, // تعديل هذه القيمة لتحديد المسافة بين الصورة والمحتوى
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildButton(
                          context,
                          "إدارة المستخدمين",
                          const Color(0xC8B7F3EC), // تحديد لون الزر
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const ManageUserAccountScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildButton(
                          context,
                          "إدارة الكتب",
                          const Color(0xC8B7F3EC),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const ManageBooksScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildButton(
                          context,
                          "إضافة كتاب الكتروني",
                          const Color(0xC8B7F3EC),
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddEbookPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// دالة لإنشاء زر مخصص مع تخصيص الألوان
  static Widget _buildButton(
      BuildContext context,
      String text,
      Color buttonColor,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor, // استخدام backgroundColor
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.changa(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
