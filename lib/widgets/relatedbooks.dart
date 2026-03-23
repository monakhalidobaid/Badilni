import 'package:flutter/material.dart';

import '../screens/electronic_book_details_screen.dart';
import 'book_details_page.dart';
//
class RelatedBooks extends StatelessWidget {
  final List<Map<String, String>>bookData;
  const RelatedBooks({super.key,required this.bookData,});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220, // ارتفاع القائمة يمكن تعديله حسب الحاجة
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // تمرير أفقي
        itemCount: bookData.length,
        itemBuilder: (context, index) {
          final book = bookData[index];
          return GestureDetector(
            onTap: () {
              final currentBook = book;
              final currentCategory = (currentBook['genre'] ?? currentBook['category'] ?? '').toLowerCase();
              // حساب قائمة توصيات ديناميكية بناءً على التصنيف مع استبعاد الكتاب الحالي
              final dynamicRelatedBooks = bookData.where((b) {
                final bCategory = (b['genre'] ?? b['category'] ?? '').toLowerCase();
                return bCategory == currentCategory && (b['title'] ?? '') != (currentBook['title'] ?? '');
              }).toList();

              if (currentBook.containsKey('status')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EelectronicBookDetailsPage(
                      bookData: currentBook,
                      relatedBook: dynamicRelatedBooks,
                    ),
                  ),
                ).whenComplete(() {
                  FocusManager.instance.primaryFocus?.unfocus();
                });
              } else if (currentBook.containsKey('condition') && currentBook.containsKey('exchangeStatus')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsPage(
                      bookData: currentBook,
                      relatedBook: dynamicRelatedBooks,
                    ),
                  ),
                ).whenComplete(() {
                  FocusManager.instance.primaryFocus?.unfocus();
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailsPage(
                      bookData: currentBook,
                      relatedBook: dynamicRelatedBooks,
                    ),
                  ),
                ).whenComplete(() {
                  FocusManager.instance.primaryFocus?.unfocus();
                });
              }
            },

            child: Container(
              width: 120, // عرض كل عنصر في القائمة
              margin: const EdgeInsets.all(8), // مسافة حول العنصر
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة الغلاف
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                       book['coverImage']?.isNotEmpty == true
                      ? book['coverImage']!
                        : "assets/img/imgtest.jpeg", width: 120,
                        height: 50,
                        fit: BoxFit.cover,),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // عنوان الكتاب
                  Text(
                    book['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
