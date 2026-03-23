import 'package:badilni_v1/screens/payment_page.dart';
import 'package:badilni_v1/screens/profile_screen.dart';
import 'package:badilni_v1/style/styled_text.dart';
import 'package:badilni_v1/theme/app_theme.dart';
import 'package:badilni_v1/widgets/custom_bottom_nav.dart';
import 'package:badilni_v1/widgets/primary_button.dart';
import 'package:badilni_v1/widgets/relatedbooks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/my_library.dart';
//
class EelectronicBookDetailsPage extends StatefulWidget {
  final Map<String, String> bookData;
  final List<Map<String, String>> relatedBook;


  const EelectronicBookDetailsPage({super.key, required this.bookData,required this.relatedBook});

  @override
  State<EelectronicBookDetailsPage> createState() => _EelectronicBookDetailsPageState();
}
class _EelectronicBookDetailsPageState extends State<EelectronicBookDetailsPage> {
  int _selectedIndex = 1; // الصفحة الافتراضية هي الرئيسية
  bool _isChecking = false; // لإظهار مؤشر تحميل أثناء التحقق

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    print("بيانات الكتاب: ${widget.bookData}");
  }

  // دالة التحقق من شروط الاستعارة
  Future<void> _checkBorrowConditions() async {
    setState(() {
      _isChecking = true;
    });

    // الحصول على المستخدم الحالي
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى تسجيل الدخول أولاً")),
      );
      setState(() {
        _isChecking = false;
      });
      return;
    }
    String userID = user.uid;

    final DatabaseReference borrowRef =
    FirebaseDatabase.instance.ref().child("borrowRecords");

    // التحقق مما إذا كانت العقدة موجودة أم لا
    final DatabaseEvent event = await borrowRef.once();

    // 1) التحقق من أن المستخدم لا يملك أي استعارة حالية لم تنتهِ بعد
    final userBorrowsSnapshot =
    await borrowRef.orderByChild("userID").equalTo(userID).get();

    bool hasActiveBorrow = false;
    if (userBorrowsSnapshot.exists) {
      for (var child in userBorrowsSnapshot.children) {
        final data = Map<String, dynamic>.from(child.value as Map);
        DateTime endDate = DateTime.parse(data['endDate']);
        if (DateTime.now().isBefore(endDate)) {
          hasActiveBorrow = true;
          break;
        }
      }
    }
    if (hasActiveBorrow) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لا يمكنك استعارة كتاب آخر قبل انتهاء استعارتك الحالية"),
        ),
      );
      setState(() {
        _isChecking = false;
      });
      return;
    }

    // 2) التحقق من أن المستخدم لم يقم باستعارة هذا الكتاب من قبل وما زالت استعارة الكتاب سارية
    final sameBookSnapshot =
    await borrowRef.orderByChild("book_id").equalTo(widget.bookData['book_id']).get();

    bool userAlreadyBorrowedThisBook = false;
    if (sameBookSnapshot.exists) {
      for (var child in sameBookSnapshot.children) {
        final data = Map<String, dynamic>.from(child.value as Map);
        DateTime endDate = DateTime.parse(data['endDate']);
        if (data['userID'] == userID && DateTime.now().isBefore(endDate)) {
          userAlreadyBorrowedThisBook = true;
          break;
        }
      }
    }
    if (userAlreadyBorrowedThisBook) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لقد استعرته سابقًا ولم تنتهِ فترة الاستعارة بعد"),
        ),
      );
      setState(() {
        _isChecking = false;
      });
      return;
    }

    // 3) التحقق من أن الكتاب غير مستعار حاليًا من قبل مستخدم آخر
    bool bookIsBorrowedBySomeoneElse = false;
    if (sameBookSnapshot.exists) {
      for (var child in sameBookSnapshot.children) {
        final data = Map<String, dynamic>.from(child.value as Map);
        DateTime endDate = DateTime.parse(data['endDate']);
        if (data['userID'] != userID && DateTime.now().isBefore(endDate)) {
          bookIsBorrowedBySomeoneElse = true;
          break;
        }
      }
    }
    if (bookIsBorrowedBySomeoneElse) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("عذرًا، هذا الكتاب مستعار حاليًا من مستخدم آخر"),
        ),
      );
      setState(() {
        _isChecking = false;
      });
      return;
    }

    setState(() {
      _isChecking = false;
    });
    // إذا لم يكن هناك أي مشاكل في الشروط، يتم الانتقال إلى صفحة الدفع وتمرير بيانات الكتاب
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentPage(bookData: widget.bookData)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.primaryAccent),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: _buildBookDetailsPage(),
      ),
    );
  }

  Widget _buildBookDetailsPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 160,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade400,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.bookData['coverImage']?.isNotEmpty == true
                          ? widget.bookData['coverImage']!
                          : "assets/img/imgtest.jpeg",
                      width: 160,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    width: 200,
                    height: 300,
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 20, 12, 59),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade400,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StyledText(widget.bookData['title']!),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BodyMedium("المؤلف: ${widget.bookData['author']}"),
                            const SizedBox(height: 8),
                            BodyMedium("التصنيف: ${widget.bookData['category']}"),
                            const SizedBox(height: 8),
                            BodyMedium("حجم ملف: ${widget.bookData['size']}"),
                            const SizedBox(height: 8),
                            BodyMedium("السعر: ${widget.bookData['price']}  ريال/شهريًا"),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeadlineMedium("نبذة:"),
                    const SizedBox(height: 8),
                    Text(
                      widget.bookData['description']!,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // استخدام _checkBorrowConditions عند الضغط على زر "استعارة لمدة 30 يوم"
                  SizedBox(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:AppTheme.primaryColor, // لون البوردر
                        textStyle: const TextStyle(fontSize: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4), // زوايا خفيفة الانحناء
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 13.0,
                          horizontal: 60.0,
                        ), // حشوة صغيرة لجعل الزر أنحف
                        minimumSize: Size.zero,                // السماح للزر بأن يصبح صغيراً جداً
                        visualDensity: VisualDensity.compact,  // تقليل المساحات الافتراضية
                      ),
                      onPressed: _isChecking
                          ? null
                          : () {
                        _checkBorrowConditions();
                      },
                      child: Text(
                        _isChecking ? "جار التحقق..." : "استعارة لمدة 30 يوم",
                        style: GoogleFonts.changa(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            if (widget.relatedBook.isNotEmpty) ...[
              const Text(
                "كتب ذات صلة",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              RelatedBooks(bookData: widget.relatedBook),
            ],
          ],
        ),
      ),
    );
  }
}

