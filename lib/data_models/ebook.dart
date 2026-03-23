import 'package:badilni_v1/data_models/book.dart';
import 'package:firebase_database/firebase_database.dart';

//
class E_book extends Book {
  final int price;
  final int size;
  final String pdf_url;

  E_book({
    required String title,
    required String author,
    required String genre,
    required String image,
    required String status,
    required this.price,
    required this.size,
    required this.pdf_url,

    required String description,
  }) : super(
    title: title,
    author: author,
    genre: genre,
    image: image,
    status: status,
    description: description,
  );


  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
//عدلت هنا عشان اقراء الحالة
  Future<List<Map<String, String>>> displayEBookInfo() async {
    List<Map<String, String>> fetchedBooks = [];

    try {
      final snapshot = await _dbRef.child('E_book').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        for (final entry in data.entries) {


          final value = entry.value as Map<dynamic, dynamic>;

          // قراءة الحقول الأساسية للكتاب الإلكتروني
          final title = value['title'] as String? ?? '';
          final author = value['author'] as String? ?? '';
          final genre = value['genre'] as String? ?? '';
          final description = value['description'] as String? ?? '';
          final image = value['image'] as String? ?? '';
          final price = value['price']?.toString() ?? '0';
          final size = value['size']?.toString() ?? '0';
          final pdf_url = value['pdf_url'] as String? ?? '';

          // التعامل مع الـ status كقيمة bool
          bool statusBool = false;
          if (value['status'] is bool) {
            statusBool = value['status'] as bool;
          }
          // تحويلها لنص، مثلاً 'true' أو 'false'
          final statusString = statusBool ? 'true' : 'false';

          // إضافة بيانات الكتاب إلى القائمة
          fetchedBooks.add({
            "title": title,
            "author": author,
            "coverImage": image, // اسم المفتاح مطابق لتصميم BookGrid
            "category": genre, // التصنيف يستخدم مفتاح "category"
            "description": description,
            "price": price,
            "size": size,
            "status": statusString,
            "pdf_url":pdf_url,
          });
        }
      }
    } catch (e) {
      print('Error fetching e-books: $e');
    }

    return fetchedBooks;
  }
}
