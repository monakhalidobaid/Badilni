import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../widgets/book_grid.dart';
import '../../widgets/custom_appbar.dart';


class BrowseProfile extends StatefulWidget {
  final String uid; // إضافة uid كمتحول داخل widget

  const BrowseProfile({super.key, required this.uid});

  @override
  State<BrowseProfile> createState() => _BrowseProfileState();
}


class _BrowseProfileState extends State<BrowseProfile> {
  List<Map<String, dynamic>> userBooks = [];
  bool isLoading = true; // متغير لتتبع حالة التحميل


  String userName = '';  // تخزين اسم المستخدم
  String userEmail = ''; // تخزين البريد الإلكتروني
  double userRate = 0.0; // تخزين التقييم
  String showRate = ''; // تعريف المتغير بدون استخدام userRate مباشرة

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserBooks();// استدعاء دالة جلب بيانات المستخدم
    showRate = userRate.toString(); // تهيئة showRate بعد تحميل userRate

  }
  void _fetchUserData() {
    _dbRef.child('reader').child(widget.uid).onValue.listen((event) {
      // استخدام casting آمن إلى Map أو null
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          userName = data['name'] ?? 'غير معروف';
          userEmail = data['email'] ?? 'غير متوفر';
          userRate = double.tryParse(data['rate']?.toString() ?? '0.0') ?? 0.0;
          showRate = userRate.toString(); // تحديث showRate عند جلب البيانات

        });
      }
    });
  }
  void _fetchUserBooks() async {
    setState(() {
      isLoading = true; // عند بدء جلب البيانات، عرض مؤشر التحميل
    });
    _dbRef
        .child('Printed_books')
        .orderByChild('uid')
        .equalTo(widget.uid)
        .onValue
        .listen((event) async {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        List<Future<Map<String, dynamic>>> bookFutures = [];

        data.forEach((key, value) {
          bookFutures.add(_buildBookMap(value));
        });

        // انتظر اكتمال جميع عمليات استرجاع بيانات الكتب دفعة واحدة
        userBooks = await Future.wait(bookFutures);

      } else {
        userBooks.clear();
      }

      // تأكد من تحديث isLoading إلى false بعد إكمال الجلب
      setState(() {
        isLoading = false;
      });
    });
  }

// دالة مساعدة لتحسين استرجاع بيانات الكتب والمستخدمين المرتبطين
  Future<Map<String, dynamic>> _buildBookMap(Map<dynamic, dynamic> value) async {
    final title = value['title'] ?? '';
    final author = value['author'] ?? '';
    final coverImage = value['image'] ?? '';
    final category = value['genre'] ?? '';
    final condition = value['condition'] ?? '';
    final state = value['state'] ?? '';
    final description = value['description'] ?? '';
    final uid = value['uid'] ?? '';

    String exchangeStatus;
    if (state == 'exchangeWithoutReturn') {
      exchangeStatus = 'تبادل بدون ارجاع';
    } else if (state == 'exchangeWithReturn') {
      exchangeStatus = 'تبادل مع ارجاع خلال 60 يوم';
    } else {
      exchangeStatus = 'غير متاح لتبادل';
    }

    String userName = 'غير معروف';
    String userPhone = 'غير معروف';

    if (uid.isNotEmpty) {
      final readerSnapshot = await _dbRef.child('reader').child(uid).get();
      // تحويل آمن للبيانات
      final readerData = readerSnapshot.value as Map<dynamic, dynamic>?;
      if (readerData != null) {
        userName = readerData['name'] as String? ?? 'غير معروف';
        userPhone = readerData['phone'] as String? ?? 'غير معروف';
      }
    }

    return {
      "title": title,
      "author": author,
      "coverImage": coverImage,
      "category": category,
      "condition": condition,
      "exchangeStatus": exchangeStatus,
      "description": description,
      "userName": userName,
      "userPhone": userPhone,
      "uid": uid,
    };
  }

  Future<void> submitUserRating(double newRating) async {
    final userRef = _dbRef.child('reader').child(widget.uid);

    await userRef.runTransaction((mutableData) {
      if (mutableData == null || mutableData is! Map) {
        return Transaction.success({
          'ratings': {
            'sum': newRating,
            'count': 1,
          },
          'rate': newRating.toStringAsFixed(1),
        });
      }

      // تحويل البيانات إلى Map آمن
      Map<dynamic, dynamic> userData = Map<dynamic, dynamic>.from(mutableData as Map<dynamic, dynamic>);

      // قراءة بيانات التقييم الحالية بأمان
      final ratingsData = userData['ratings'] as Map<dynamic, dynamic>? ?? {};
      double oldSum = double.tryParse(ratingsData['sum']?.toString() ?? '0') ?? 0.0;
      int oldCount = int.tryParse(ratingsData['count']?.toString() ?? '0') ?? 0;

      // تحديث القيم
      double newSum = oldSum + newRating;
      int newCount = oldCount + 1;
      double newAverage = newSum / newCount;

      // تحديث بيانات التقييم في userData
      userData['ratings'] = {
        'sum': newSum,
        'count': newCount,
      };
      userData['rate'] = newAverage.toStringAsFixed(1);

      return Transaction.success(userData);
    }).then((result) {
      if (result.committed) {
        print("✅ تم تحديث التقييم بنجاح!");
      } else {
        print("❌ لم يتم تحديث التقييم.");
      }
    }).catchError((error) {
      print("⚠️ حدث خطأ أثناء تحديث التقييم: $error");
    });
  }




  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضمان أن المحتوى من اليمين لليسار
      child: Scaffold(
        appBar: CustomAppBar(),

        backgroundColor: Colors.white,
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
                  buildRatingStars(userRate),
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
                child: isLoading
                    ? Center(child: CircularProgressIndicator()) // عرض مؤشر تحميل أثناء جلب البيانات
                    : userBooks.isEmpty
                    ? Center(child: Text('لا توجد كتب متاحة'))
                    : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child:  BookGrid(
                  books: userBooks.map((book) {
                    return book.map((key, value) => MapEntry(key, value.toString()));
                  }).toList(),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

// دالة لإنشاء قائمة النجوم الخاصة بالتقييم
  // داخل _BrowseProfileState
  Widget buildRatingStars(double rating) {
    bool isOwner = widget.uid == auth.currentUser?.uid;

    if (isOwner) {
      return RatingBarIndicator(
        rating: rating,
        itemBuilder: (context, index) => const Icon(
          Symbols.star,
          color: Colors.orangeAccent,
        ),
        itemCount: 5,
        itemSize: 25,
        direction: Axis.horizontal,
      );
    } else {
      return RatingBar.builder(
        initialRating: rating,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemSize: 25,
        itemBuilder: (context, _) => const Icon(
          Symbols.star,
          color: Colors.orangeAccent,
        ),
        onRatingUpdate: (newRating) async {
          await submitUserRating(newRating);
        },
      );
    }
  }


}