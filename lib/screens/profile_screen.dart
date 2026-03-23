import 'package:badilni_v1/screens/reader/add_book_screen.dart';
import 'package:badilni_v1/screens/reader/borrowing_record.dart';
import 'package:badilni_v1/screens/reader/edit_printedBook_screen.dart';
import 'package:badilni_v1/screens/reader/edit_profile.dart';
import 'package:badilni_v1/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../widgets/custom_appbar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

//
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

String userName='';
String userEmail='';
String userRate='';


final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
final FirebaseAuth auth = FirebaseAuth.instance;


class _ProfileScreenState extends State<ProfileScreen> {
  String showRate = ''; // تعريف المتغير بدون استخدام userRate مباشرة

  @override
  void initState() {
    super.initState();
    listenToProfileData();
    listenToBookInfo();
    showRate = userRate.toString(); // تهيئة showRate بعد تحميل userRate

  }



  void listenToProfileData() {
    _dbRef.child('reader').child(auth.currentUser!.uid).onValue.listen((event) {
      final snapshot = event.snapshot;
      setState(() {
        userName = snapshot.child("name").value as String? ?? '';
        userEmail = snapshot.child("email").value as String? ?? '';
        userRate = snapshot.child("rate").value as String? ?? '';
        userRating = double.parse(userRate);
        showRate = userRate.toString();
      });
      print('userRating is : $userRating');
    });
  }


  final List<Map<String, String>> books = [];

  Future<List<Map<String, String>>> displayBookInfo() async {
    List<Map<String, String>> fetchedBooks = [];

    try {
      final snapshot = await _dbRef.child('Printed_books').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        for (final entry in data.entries) {
          final value = entry.value;
          final title = value['title'] as String? ?? '';
          final author = value['author'] as String? ?? '';
          final genre = value['genre'] as String? ?? '';
          final description = value['description'] as String? ?? '';
          final condition = value['condition'] as String? ?? '';
          final state = value['state'] as String? ?? '';
          final image = value['image'] as String? ?? '';
          final uid = value['uid'] as String? ?? '';
          final book_id = entry.key.toString();

          print("book id is :   $book_id");

          // تحويل حقل state إلى جملة عربية
          String exchangeStatus;
          if (state == 'exchangeWithoutReturn') {
            exchangeStatus = 'تبادل بدون ارجاع';
          } else if (state == 'exchangeWithReturn') {
            exchangeStatus = 'تبادل مع ارجاع خلال 60 يوم';
          } else {
            exchangeStatus = 'غير متاح لتبادل';
          }
          if(auth.currentUser!.uid ==uid) {
            // إضافة بيانات الكتاب + بيانات المستخدم إلى القائمة
            fetchedBooks.add({
              "title": title,
              "author": author,
              "coverImage": image, // لكي يتوافق مع BookGrid
              "category": genre, // في التصميم الأصلي استخدمت "category"
              "condition": condition,
              "exchangeStatus": exchangeStatus,
              "description": description,
              "book_id" : book_id
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching books: $e');
    }

    setState(() {
      books.addAll(fetchedBooks);
    });

    return fetchedBooks;
  }

  void listenToBookInfo() {
    _dbRef.child('Printed_books').onValue.listen((event) {
      List<Map<String, String>> fetchedBooks = [];
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        for (final entry in data.entries) {
          final value = entry.value;
          final title = value['title'] as String? ?? '';
          final author = value['author'] as String? ?? '';
          final genre = value['genre'] as String? ?? '';
          final description = value['description'] as String? ?? '';
          final condition = value['condition'] as String? ?? '';
          final state = value['state'] as String? ?? '';
          final image = value['image'] as String? ?? '';
          final uid = value['uid'] as String? ?? '';
          final book_id = entry.key.toString();

          String exchangeStatus;
          if (state == 'exchangeWithoutReturn') {
            exchangeStatus = 'تبادل بدون ارجاع';
          } else if (state == 'exchangeWithReturn') {
            exchangeStatus = 'تبادل مع ارجاع خلال 60 يوم';
          } else {
            exchangeStatus = 'غير متاح لتبادل';
          }
          if (auth.currentUser!.uid == uid) {
            fetchedBooks.add({
              "title": title,
              "author": author,
              "coverImage": image,
              "category": genre,
              "condition": condition,
              "exchangeStatus": exchangeStatus,
              "description": description,
              "book_id": book_id
            });
          }
        }
      }
      setState(() {
        books.clear();
        books.addAll(fetchedBooks);
      });
    });
  }

  double userRating = 0.0; // التقييم الافتراضي

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضمان أن المحتوى من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: "الملف الشخصي",
            centerTitle: true
        ),

        drawer: buildSideMenu(context),
        // استخدام Column بدلاً من ListView للسماح باستخدام Expanded
        body: Column(
          children: [
            // القسم العلوي للمعلومات الشخصية
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
              child: Column(
                children: [
                  Container(
                    height: 115,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(width: 4, color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 2,
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(userEmail),
                  const SizedBox(height: 10),
                  buildRatingStars(userRating),
                  Text(showRate, style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: Divider(
                  color: Colors.grey[200],
                  thickness: 2,
                  height: 20
              ),
            ),
            SizedBox(height: 10),
            // القسم الخاص ببطاقات الكتب بحيث يشغل باقي الشاشة
            Expanded(
              child: BookGridss(books: books),
            ),

          ],
        ),
      ),
    );
  }

  // دالة لإنشاء قائمة النجوم الخاصة بالتقييم
  Widget buildRatingStars(double rating) {
    return RatingBarIndicator(
      rating: rating,
      itemSize: 25, // تكبير حجم النجوم

      itemBuilder: (context, _) => const Icon(
        Symbols.star, // نجمة بحواف ناعمة
        color: Colors.orangeAccent, // لون أكثر إشراقًا
      ),
      itemCount: 5,
      direction: Axis.horizontal,
    );
  }

  // دالة لإنشاء القائمة الجانبية (Drawer)
  Widget buildSideMenu(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white, // تغيير لون الخلفية هنا

      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: 70),
          buildMenuOption(
            icon: Symbols.library_add,
            text: "إضافة كتاب",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddBookScreen()),
              ).then((result) {
                if (result == true) {
                  setState(() {
                    books.clear(); // مسح الكتب القديمة
                  });
                  displayBookInfo(); // إعادة جلب الكتب وتحديث القائمة
                }
              });
            },
          ),
          const Divider(),
          buildMenuOption(
            icon: Symbols.edit_square,
            text: "تعديل الملف الشخصي",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditProfile()));
            },
          ),   const Divider(),
          buildMenuOption(
            icon: Symbols.history,
            text: "سجل الاستعارات السابقة",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => BorrowingRecord()));
            },
          ),
          const Divider(),
          buildMenuOption(
            icon: Symbols.logout,
            text: "تسجيل خروج",
            color: Colors.red, // تغيير لون النص إلى الأحمر
            onTap: () async {
              await FirebaseAuth.instance.signOut();

              // إظهار رسالة التأكيد
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("تم تسجيل الخروج بنجاح"),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );

              // الانتقال إلى شاشة الترحيب بعد تسجيل الخروج
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // دالة لإنشاء عناصر القائمة الجانبية
  Widget buildMenuOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22, color: color),
      title: Text(text, style: TextStyle(fontSize: 17, color: color)),
      onTap: onTap,
    );
  }
}





//
class BookGridss extends StatelessWidget {
  final List<Map<String, String>> books;

  const BookGridss({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // عدد الأعمدة
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            final currentBook = books[index];

            Navigator.push(

              context,
                MaterialPageRoute(
                  builder: (context) => EditPrintedBook(
                    book_id : currentBook['book_id'] as String,
                  ),
                ),
              ).whenComplete(() {
                FocusManager.instance.primaryFocus?.unfocus();
              });
            } ,
          child: Card(
            color: Colors.grey[100],

            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: Column(

              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    child:Image.network(
                      books[index]['coverImage']! ,fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    books[index]['title']!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    books[index]['author']!,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
