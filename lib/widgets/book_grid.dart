import 'package:badilni_v1/widgets/book_details_page.dart';
import 'package:flutter/material.dart';

import '../screens/electronic_book_details_screen.dart';
//
class BookGrid extends StatelessWidget {
  final List<Map<String, String>> books;
  final List<Map<String, String>> relatedBook;

  //TODO غيرت الرليتد بوك لمعامل اختياري بنشوف لو صار اي مشاكل برجعها معامل الزامي
  const BookGrid({super.key, required this.books,  this.relatedBook = const []});

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
            final currentCategory = (currentBook['genre'] ?? currentBook['category'] ?? '').toLowerCase();
            // استخدام القائمة الممررة (التي هي القائمة الكاملة) لحساب الكتب ذات الصلة
            final dynamicRelatedBooks = relatedBook.where((b) {
              final bCategory = (b['genre'] ?? b['category'] ?? '').toLowerCase();
              return bCategory == currentCategory && (b['title'] ?? '') != (currentBook['title'] ?? '');
            }).toList();

            if (currentBook.containsKey('price') && currentBook.containsKey('size')) {
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
                      books[index]['coverImage']! , fit: BoxFit.cover,
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
