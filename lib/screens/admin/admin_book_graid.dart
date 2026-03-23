
import 'package:badilni_v1/screens/admin/admin_edit_ebook.dart';
import 'package:badilni_v1/screens/admin/admin_edit_printed_book.dart';
import 'package:flutter/material.dart';


class AdminBookGraid extends StatelessWidget {
  final List<Map<String, String>> books;

  const AdminBookGraid({super.key, required this.books});

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

            if (currentBook.containsKey('price') && currentBook.containsKey('size')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminEditEbook(
                    book_id : currentBook['book_id'] as String,
                  ),
                ),
              ).whenComplete(() {
                FocusManager.instance.primaryFocus?.unfocus();
              });
            } else if (currentBook.containsKey('condition') && currentBook.containsKey('exchangeStatus')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminEditPrintedBook(
                    book_id : currentBook['book_id'] as String,
                  ),
                ),
              ).whenComplete(() {
                FocusManager.instance.primaryFocus?.unfocus();
              });
            }
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
                    ),  child:Image.network(
                      books[index]['coverImage']! ,
                    width: double.infinity,
                    height: double.infinity,
                      fit: BoxFit.cover,),
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

