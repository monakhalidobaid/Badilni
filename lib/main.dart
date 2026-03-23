import 'package:badilni_v1/providers/borrowed_books_provider.dart';
import 'package:badilni_v1/providers/my_auth_provider.dart';
import 'package:badilni_v1/screens/admin/add_ebook_screen.dart';
import 'package:badilni_v1/screens/admin/admin_home_screen.dart';
import 'package:badilni_v1/screens/admin/manage_books_screen.dart';
import 'package:badilni_v1/screens/home_screen.dart';
import 'package:badilni_v1/screens/intro_screen.dart';
import 'package:badilni_v1/screens/payment_page.dart';
import 'package:badilni_v1/screens/reader/add_book_screen.dart';
import 'package:badilni_v1/screens/reader/edit_printedBook_screen.dart';
import 'package:badilni_v1/screens/welcome_screen.dart';
import 'package:badilni_v1/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // تأكد من تهيئة Flutter قبل Firebase

  await Firebase.initializeApp(); // تهيئة Firebase
  await Supabase.initialize(
    url: 'https://flevnooqayosayzqbddt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZsZXZub29xYXlvc2F5enFiZGR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIwMzg1MTMsImV4cCI6MjA1NzYxNDUxM30.4vYkQxDb4dgYnyRELsFh_z__SyjizhorUcxfak9kPUU',
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyAuthProvider()),
        ChangeNotifierProvider(create: (context) => BorrowedBooksProvider()),

      ],
      child: const MyApp(),
    ),
  );}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme, // تطبيق الثيم
      debugShowCheckedModeBanner: false,
      home: const Directionality(
        textDirection: TextDirection.rtl, // يجعل النصوص تبدأ من اليمين
        child: IntroScreen()
        //HomeScreen(),
        //WelcomeScreen(), // الصفحة الرئيسية
      ),
    );
  }
}
