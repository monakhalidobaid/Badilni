import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class Book {
  String title;
  String author;
  String genre;
  String image;
  String status;
  String description;


  Book({
    required this.title,
    required this.author,
    required this.genre,
    required this.image,
    required this.status,
    required this.description,
  });

}

