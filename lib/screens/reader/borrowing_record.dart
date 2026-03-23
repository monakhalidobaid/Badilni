import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_search_field.dart';

class BorrowingRecord extends StatefulWidget {
  const BorrowingRecord({Key? key}) : super(key: key);

  @override
  _BorrowingRecordState createState() => _BorrowingRecordState();
}

class _BorrowingRecordState extends State<BorrowingRecord> {
  final TextEditingController _searchController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;

  final List<Map<String, String>> books = [];
  String searchQuery = '';

  Future<void> displayBookInfo() async {
    final user = auth.currentUser;
    if (user == null) return;

    final uid = user.uid;
    List<Map<String, String>> fetchedBooks = [];

    try {
      final snapshot = await _dbRef.child('borrowRecords')
          .orderByChild("userID")
          .equalTo(uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          final title = value['title'] as String? ?? '';
          final rawStartDate = value['startDate']?.toString() ?? '';
          final rawEndDate = value['endDate']?.toString() ?? '';
          final price = value['price']?.toString() ?? '';
          final bookId = key.toString();

          String formattedStartDate = rawStartDate;
          String formattedEndDate = rawEndDate;

          try {
            DateTime startDateTime = DateTime.parse(rawStartDate);
            formattedStartDate = intl.DateFormat('dd MMM yyyy, ').format(startDateTime);
          } catch (_) {}

          try {
            DateTime endDateTime = DateTime.parse(rawEndDate);
            formattedEndDate = intl.DateFormat('dd MMM yyyy, ').format(endDateTime);
          } catch (_) {}

          fetchedBooks.add({
            "title": title,
            "startDate": formattedStartDate,
            "endDate": formattedEndDate,
            "price": price,
            "book_id": bookId,
          });
        });
      }
    } catch (e) {
      print('Error fetching books: $e');
    }

    setState(() {
      books.clear();
      books.addAll(fetchedBooks);
    });
  }

  @override
  void initState() {
    super.initState();
    displayBookInfo();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = books.where((book) {
      final title = book['title'] ?? '';
      return title.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: "سجل الاستعارات السابقة",
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomSearchField(
                controller: _searchController,
                onSearch: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                onClear: () {
                  _searchController.clear();
                  setState(() {
                    searchQuery = '';
                  });
                },
                hintText: "ابحث عن كتاب",
              ),
            ),
            Expanded(
              child: filteredBooks.isEmpty
                  ? const Center(child: Text("لا توجد نتائج مطابقة"))
                  : ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  var record = filteredBooks[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -2),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'عنوان الكتاب: ${record['title']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'تاريخ الاستعارة: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  record['startDate'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'تاريخ الانتهاء: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  record['endDate'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'السعر: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('${record['price']} ريال'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
