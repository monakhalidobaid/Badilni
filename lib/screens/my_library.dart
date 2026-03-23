import 'dart:async';
import 'package:badilni_v1/screens/ebook_reader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';

class MyLibrary extends StatefulWidget {
  const MyLibrary({Key? key}) : super(key: key);

  @override
  State<MyLibrary> createState() => _MyLibraryState();
}

class _MyLibraryState extends State<MyLibrary> {
  // نخزن جميع بيانات الاستعارة كما هي من Firebase
  List<Map<String, dynamic>> allBorrowedBooks = [];
  bool _isLoading = true;
  late DatabaseReference borrowRef;
  StreamSubscription<DatabaseEvent>? _subscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _listenToBorrowedBooks();
    // تحديث الواجهة كل 30 ثانية لإعادة تقييم شرط انتهاء الاستعارة
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) setState(() {});
    });
  }

  void _listenToBorrowedBooks() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    borrowRef = FirebaseDatabase.instance.ref().child("borrowRecords");

    _subscription = borrowRef
        .orderByChild("userID")
        .equalTo(user.uid)
        .onValue
        .listen((event) {
      if (!mounted) return;
      List<Map<String, dynamic>> books = [];
      if (event.snapshot.exists) {
        for (var child in event.snapshot.children) {
          final data = Map<String, dynamic>.from(child.value as Map);
          books.add(data);
        }
      }
      setState(() {
        allBorrowedBooks = books;
        _isLoading = false;
      });
    });
  }

  // نقوم بتصفية الكتب بحيث نعرض فقط تلك التي لم تنتهِ فترة استعارتها
  List<Map<String, dynamic>> get filteredBooks {
    DateTime nowUtc = DateTime.now().toUtc();
    return allBorrowedBooks.where((data) {
      DateTime endDate = DateTime.parse(data['endDate']).toUtc();
      return nowUtc.isBefore(endDate);
    }).toList();
  }
  @override
  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var books = filteredBooks;
    // اطبع المحتوى هنا
    print("محتوى الكتب الحالية:");
    for (var book in books) {
      print(book);
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
            title: "مكتبتي الإلكترونية",
            centerTitle: true
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : books.isEmpty
            ? const Center(child: Text("لم تقم باستعارة أي كتاب بعد"))
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // عدد الأعمدة
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.6
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              // حساب المدة المتبقية باستخدام endDate من بيانات السجل
              final endDate = DateTime.parse(book['endDate']).toUtc();
              final now = DateTime.now().toUtc();
              final remainingDuration = endDate.difference(now);

              String remainingText;
              Color remainingColor;

              if (remainingDuration.inDays > 0) {
                remainingText = '${remainingDuration.inDays} يوم';
                remainingColor = Colors.green[800]!; // أخضر داكن
              } else if (remainingDuration.inHours > 0) {
                remainingText = '${remainingDuration.inHours} ساعة';
                remainingColor = Colors.yellow[800]!; // أصفر داكن
              } else if (remainingDuration.inMinutes > 0) {
                remainingText = '${remainingDuration.inMinutes} دقيقة';
                remainingColor = Colors.red[800]!; // أحمر داكن
              } else {
                remainingText = 'انتهت';
                remainingColor = Colors.grey;
              }


              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EbookReader(pdf_url: book['pdf_url'],title: book['title']),
                    ),
                  );
                },
                child: Card(
                  color: Colors.grey[100],
                  elevation: 2,
                  shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),

                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          child: Image.network(
                            book['coverImage'] ?? 'https://example.com/default-cover.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          book['title'] ?? 'عنوان غير متوفر',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          book['author'] ?? 'مؤلف غير معروف',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          "المدة المتبقية: $remainingText",
                          style: TextStyle(
                            fontSize: 14,
                            color: remainingColor,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },

          ),
        ),
      ),
    );
  }
}
