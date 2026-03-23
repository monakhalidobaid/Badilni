import 'package:badilni_v1/screens/profile_screen.dart';
import 'package:badilni_v1/screens/reader/browse_profile.dart';
import 'package:badilni_v1/style/styled_text.dart';
import 'package:badilni_v1/theme/app_theme.dart';
import 'package:badilni_v1/widgets/custom_bottom_nav.dart';
import 'package:badilni_v1/widgets/primary_button.dart';
import 'package:badilni_v1/widgets/relatedbooks.dart';
import 'package:badilni_v1/widgets/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/my_library.dart';

class BookDetailsPage extends StatefulWidget {
  final Map<String, String> bookData;
  final List<Map<String, String>> relatedBook;

  const BookDetailsPage({super.key, required this.bookData, this.relatedBook = const []});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  int _selectedIndex = 1; // الصفحة الافتراضية هي الرئيسية

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        // عرض تفاصيل الكتاب فقط دون IndexedStack وشريط تنقل سفلي
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
                            BodyMedium("حالة الكتاب المادية: ${widget.bookData['condition']}"),
                            const SizedBox(height: 8),
                            BodyMedium("حالة التبادل: ${widget.bookData['exchangeStatus']}"),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min, // يمنع أخذ مساحة زائدة
                        children: [
                          IconButton(
                            icon: Icon(Icons.person, color: AppTheme.primaryAccent, size: 30),
                            padding: EdgeInsets.zero, // يمنع أي حشوة إضافية حول الزر
                            constraints: BoxConstraints(), // يزيل القيود الافتراضية للزر
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  BrowseProfile(uid: widget.bookData['uid']!),
                                ),
                              );
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  BrowseProfile(uid: widget.bookData['uid']!),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, // يجعل الزر يتناسب مع النص فقط
                              minimumSize: Size(0, 0), // إزالة القيود الافتراضية للحجم
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // تقليل المساحة القابلة للنقر
                            ),
                            child: HeadlineMedium(widget.bookData['userName']!), // اسم المستخدم
                          ),
                        ],
                      ),
                    ],
                  ),
                  SecondaryButton(
                    text: "مراسلة",
                    onPressed: () async {
                      final userPhone = widget.bookData['userPhone'];
                      if (userPhone != null && userPhone.isNotEmpty && userPhone != 'غير معروف') {
                        // تأكد من تحويل الرقم إلى التنسيق الدولي الصحيح (مثال: 966535609643)
                        final formattedPhone = "966550037776";
                        //966550037776
                        final whatsappUrl = "https://wa.me/$userPhone";
                        if (await canLaunch(whatsappUrl)) {
                          await launch(whatsappUrl);
                        } else {
                          // محاولة بديلة لفتح الرابط عبر المتصفح
                          final fallbackUrl = "https://wa.me/$userPhone";
                          if (await canLaunch(fallbackUrl)) {
                            await launch(fallbackUrl);
                          } else {
                            print("تعذر فتح واتساب");
                          }
                        }
                      } else {
                        print("رقم الهاتف غير صالح");
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // عرض الكتب ذات الصلة فقط إذا كانت القائمة غير فارغة
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
