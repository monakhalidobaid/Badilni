import 'package:badilni_v1/screens/my_library.dart';
import 'package:badilni_v1/screens/profile_screen.dart';
import 'package:badilni_v1/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data_models/ebook.dart';
import '../data_models/printedBook.dart';
import '../providers/my_auth_provider.dart';
import '../widgets/book_grid.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_search_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  final TextEditingController searchController = TextEditingController();
  int _selectedIndex = 1; // الصفحة الافتراضية هي الرئيسية

  // التصنيف المحدد (يستخدم للمؤشر وللتصفية)
  String selectedCategory = "تحديد الكل";

  // القائمة المعروضة للكتب
  List<Map<String, String>> books = [];
  // القائمة الأصلية لجميع الكتب (قبل التصفية)
  List<Map<String, String>> allBooks = [];

  // القوائم المنفصلة للكتب المطبوعة والكتب الإلكترونية
  List<Map<String, String>> printedBooksList = [];
  List<Map<String, String>> eBooksList = [];

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // قائمة التصنيفات المستخدمة في العرض
  final List<String> categories = [
    "تحديد الكل",
    "كتب إلكترونية",
    "خيالي",
    "رعب",
    "بوليسي",
    "عاطفي",
    "تاريخي",
    "تعليمي",
    "تطوير الذات",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedIndex = 1;
    _subscribeToPrintedBooks();
    _subscribeToEBooks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _selectedIndex = 1;
      });
    }
  }

  /// الاشتراك في تغييرات الكتب المطبوعة من قاعدة البيانات
  void _subscribeToPrintedBooks() {
    _dbRef.child('Printed_books').onValue.listen((event) async {
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
          printedBooks.add({
            "title": title,
            "author": author,
            "coverImage": image, // لتتوافق مع تصميم BookGrid
            "category": genre, // لتوحيد المفتاح المستخدم في التصفية
            "condition": condition,
            "exchangeStatus": exchangeStatus,
            "description": description,
            "userName": userName,    // لاحظ بدل "name" -> "userName"
            "userPhone": userPhone, // بدل "phone" -> "userPhone"
            "uid":uid,
            "book_id": book_id,
          });
        }
      }
      _updateBooks(printedBooks: printedBooks);
    });
  }

  /// الاشتراك في تغييرات الكتب الإلكترونية من قاعدة البيانات
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
            "genre": genre,
            "category": genre, // لتوحيد المفتاح المستخدم في التصفية
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

  /// دالة لدمج وتحديث الكتب بعد استلامها من Firebase
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
        final genre = (book['genre'] ?? book['category'] ?? '').toLowerCase();
        return genre.contains(category.toLowerCase());
      }).toList();
    }
    setState(() {
      books = filteredBooks;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // عند الرجوع للرئيسية، يمكن إعادة الاشتراك أو تحديث البيانات إذا لزم الأمر
    if (index == 1) {
      // يمكن إعادة الاشتراك إذا كنت بحاجة لتحديث البيانات يدويًا
    }
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);
    final userName =
    authProvider.userName.isNotEmpty ? authProvider.userName : "مستخدم";
    final bool isUserLoading = authProvider.userName.isEmpty;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _selectedIndex == 1
            ? AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: isUserLoading
                    ? Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "جار التحميل...",
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                  ],
                )
                    : Text(
                  "مرحبا $userName\nماذا تريد أن تقرأ اليوم؟",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.tajawal(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )
            : null,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(
          index: _selectedIndex,
          children: [
            const ProfileScreen(),
            _buildHomeContent(),
            const MyLibrary(),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // حقل البحث مع تفعيل الدوال onSearch و onClear
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
            hintText: "البحث بعنوان الكتاب أو المؤلف", // تخصيص النص الافتراضي
          ),
          const SizedBox(height: 16),
          // عنوان التصنيفات
          Row(
            children: [
              Expanded(
                child: Text(
                  "التصنيفات",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // منطقة التصنيفات مع تأثير المؤشر المتحرك
          buildCategoryTabs(MediaQuery.of(context).size),
          const SizedBox(height: 16),
          // عرض بطاقات الكتب أو رسالة "لاتوجد نتائج مطابقة" إذا كانت القائمة فارغة
          Expanded(
            child: books.isEmpty
                ? const Center(
              child: Text(
                "لاتوجد نتائج مطابقة",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
                : BookGrid(
              books: books,
              relatedBook: allBooks,
            ),
          ),
        ],
      ),
    );
  }

}
