import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_search_field.dart';
import 'admin_book_graid.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({Key? key}) : super(key: key);

  @override
  ManageBooksScreenState createState() => ManageBooksScreenState();
}

class ManageBooksScreenState extends State<ManageBooksScreen> {
  final TextEditingController searchController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool _isLoading = true;
  String selectedCategory = "تحديد الكل";

  // القائمة المعروضة للكتب
  List<Map<String, String>> books = [];
  // القائمة الأصلية لجميع الكتب (قبل التصفية)
  List<Map<String, String>> allBooks = [];

  // حفظ البيانات المستقبلة لكل نوع من الكتب بشكل منفصل
  List<Map<String, String>> printedBooksList = [];
  List<Map<String, String>> eBooksList = [];

  /// الاشتراك في تغييرات الكتب المطبوعة
  void _subscribeToPrintedBooks() {
    _dbRef.child('Printed_books').onValue.listen((event) {
      List<Map<String, String>> printedBooks = [];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        for (final entry in data.entries) {
          final value = entry.value;
          final title = value['title'] as String? ?? '';
          final author = value['author'] as String? ?? '';
          final genre = value['genre'] as String? ?? '';
          final description = value['description'] as String? ?? '';
          final condition = value['condition'] as String? ?? '';
          final state = value['state'] as String? ?? '';
          final image = value['image'] as String? ?? '';
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

          printedBooks.add({
            "title": title,
            "author": author,
            "coverImage": image, // لتتوافق مع تصميم BookGrid
            "category": genre,
            "condition": condition,
            "exchangeStatus": exchangeStatus,
            "description": description,
            "book_id": book_id,
          });
        }
      }
      _updateBooks(printedBooks: printedBooks);
    });
  }

  /// الاشتراك في تغييرات الكتب الإلكترونية
  void _subscribeToEBooks() {
    _dbRef.child('E_book').onValue.listen((event) {
      List<Map<String, String>> eBooks = [];
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        for (final entry in data.entries) {
          final value = entry.value;
          final title = value['title'] as String? ?? '';
          final author = value['author'] as String? ?? '';
          final genre = value['genre'] as String? ?? '';
          final description = value['description'] as String? ?? '';
          final image = value['image'] as String? ?? '';
          final price = value['price']?.toString() ?? '0';
          final size = value['size']?.toString() ?? '0';
          final pdf_url = value['pdf_url'] as String? ?? '';
          final book_id = entry.key.toString();

          bool statusBool = false;
          if (value['status'] is bool) {
            statusBool = value['status'] as bool;
          }
          final statusString = statusBool ? 'true' : 'false';

          eBooks.add({
            "title": title,
            "author": author,
            "coverImage": image,
            "category": genre,
            "description": description,
            "price": price,
            "size": size,
            "status": statusString,
            "pdf_url": pdf_url,
            "book_id": book_id,
          });
        }
      }
      _updateBooks(eBooks: eBooks);
    });
  }

  /// دالة لدمج البيانات المرسلة من مستمعي الكتب وتحديث الحالة
  void _updateBooks({List<Map<String, String>>? printedBooks, List<Map<String, String>>? eBooks}) {
    if (printedBooks != null) {
      printedBooksList = printedBooks;
    }
    if (eBooks != null) {
      eBooksList = eBooks;
    }
    List<Map<String, String>> all = [];
    all.addAll(printedBooksList);
    all.addAll(eBooksList);

    setState(() {
      allBooks = all;
      books = all;
      _isLoading = false;
    });
  }

  /// دالة لتصفية الكتب بناءً على استعلام البحث (اسم الكتاب أو المؤلف)
  void _searchBooks(String query) {
    List<Map<String, String>> filteredBooks;
    if (query.isEmpty) {
      filteredBooks = allBooks;
    } else {
      filteredBooks = allBooks.where((book) {
        final title = book['title'] ?? '';
        final author = book['author'] ?? '';
        return title.toLowerCase().contains(query.toLowerCase()) ||
            author.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    setState(() {
      books = filteredBooks;
    });
  }

  /// دالة لتصفية الكتب بناءً على التصنيف
  void _filterBooksByCategory(String category) {
    List<Map<String, String>> filteredBooks;
    if (category == "تحديد الكل") {
      filteredBooks = allBooks;
    } else if (category == "كتب إلكترونية") {
      filteredBooks = allBooks.where((book) {
        return book.containsKey("price") &&
            book["price"] != null &&
            book["price"].toString().isNotEmpty;
      }).toList();
    } else {
      filteredBooks = allBooks.where((book) {
        return book.containsKey("condition") &&
            book["condition"] != null &&
            book["condition"].toString().isNotEmpty;
      }).toList();
    }
    setState(() {
      books = filteredBooks;
    });
  }

  /// بناء منطقة التصنيفات مع تأثير المؤشر المتحرك
  Widget buildCategoryTabs(Size size) {
    return Container(
      height: 34,
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: categories
                  .asMap()
                  .entries
                  .map((entry) => _categoryButton(entry.value, entry.key))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// زر التصنيف بتصميم جديد بدون حدود، مع ألوان مميزة عند الاختيار
  Widget _categoryButton(String label, int index) {
    bool isSelected = label == selectedCategory;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.black,
          backgroundColor:
          isSelected ? const Color(0xAD46CCBD) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
        ),
        onPressed: () {
          setState(() {
            selectedCategory = label;
          });
          _filterBooksByCategory(label);
          print("تم اختيار تصنيف: $label");
        },
        child: Text(label),
      ),
    );
  }

  // قائمة التصنيفات المستخدمة في العرض
  final List<String> categories = [
    "تحديد الكل",
    "كتب إلكترونية",
    "كتب مطبوعة",
  ];

  @override
  void initState() {
    super.initState();
    // استدعاء الاشتراكات للاستماع لتغيرات الكتب
    _subscribeToPrintedBooks();
    _subscribeToEBooks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: "إدارة الكتب",
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // حقل البحث
              CustomSearchField(
                controller: searchController,
                onSearch: (query) {
                  _searchBooks(query);
                  print("البحث عن: $query");
                },
                onClear: () {
                  searchController.clear();
                  _searchBooks('');
                },
              ),
              const SizedBox(height: 16),
              // أزرار الفلترة
              buildCategoryTabs(MediaQuery.of(context).size),
              const SizedBox(height: 16),
              // عرض الكتب في Grid
              Expanded(
                child: AdminBookGraid(books: books),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
