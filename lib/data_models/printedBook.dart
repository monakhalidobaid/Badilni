import 'package:badilni_v1/data_models/book.dart';
import 'package:firebase_database/firebase_database.dart';

//
class Printedbook extends Book {
  Printedbook({
    required String title,
    required String author,
    required String genre,
    required String image,
    required String status,
    required String description,
    required String condition,
  })
      : super(
    title: title,
    author: author,
    genre: genre,
    image: image,
    status: status,
    description: description,
  );
  //لاتصال بقاعدة البيانات
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Future<void> insertPrintedBook(String uid, String title, String author,
      String genre, String image , String description , String condition, String state) async {
    await _dbRef.child("Printed_books").push().set({    // push to get generate def id
      'uid': uid,
      'title': title,
      'author': author,
      'genre': genre,
      'description': description,
      'image': image,
      'condition': condition,
      'image':image,
      'state':state
    });
    print("تم التسجيل وتخزين بيانات المستخدم بنجاح");
  }



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

          // تحويل حقل state إلى جملة عربية
          String exchangeStatus;
          if (state == 'exchangeWithoutReturn') {
            exchangeStatus = 'تبادل بدون ارجاع';
          } else if (state == 'exchangeWithReturn') {
            exchangeStatus = 'تبادل مع ارجاع خلال 60 يوم';
          } else {
            exchangeStatus = 'غير متاح لتبادل';
          }

          // جلب بيانات المستخدم بناءً على uid
          String userName = 'غير معروف';
          String userPhone = 'غير معروف';
          if (uid.isNotEmpty) {
            final readerSnapshot = await _dbRef.child('reader').child(uid).get();
            if (readerSnapshot.exists) {
              final readerData = readerSnapshot.value as Map<dynamic, dynamic>;
              userName = readerData['name'] as String? ?? 'غير معروف';
              userPhone = readerData['phone'] as String? ?? 'غير معروف';
            }
          }

          // إضافة بيانات الكتاب + بيانات المستخدم إلى القائمة
          fetchedBooks.add({
            "title": title,
            "author": author,
            "coverImage": image,     // لكي يتوافق مع BookGrid
            "category": genre,       // في التصميم الأصلي استخدمت "category"
            "condition": condition,
            "exchangeStatus": exchangeStatus,
            "description": description,
            "userName": userName,    // لاحظ بدل "name" -> "userName"
            "userPhone": userPhone, // بدل "phone" -> "userPhone"
            "uid":uid,
            "book_id" : book_id

          });
        }
      }
    } catch (e) {
      print('Error fetching books: $e');
    }

    return fetchedBooks;
  }

  }
