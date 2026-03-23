import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
//
abstract class User {
  String uid;
  String email;
  String username;

  User({
    required this.uid,
    required this.email,
    required this.username,
  });
}