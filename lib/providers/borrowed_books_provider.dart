import 'package:flutter/material.dart';

class BorrowedBooksProvider with ChangeNotifier {
  final List<Map<String, String>> _borrowedBooks = [];

  List<Map<String, String>> get borrowedBooks => _borrowedBooks;

  void addBorrowedBook(Map<String, String> book) {
    _borrowedBooks.add(book);
    notifyListeners();
  }
}
