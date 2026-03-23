import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

//
class MyAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  User? get currentUser => _auth.currentUser;

  // متغير لتخزين اسم المستخدم بعد تسجيل الدخول
  String _userName = '';
  String get userName => _userName;

  // المُنشئ الذي يستدعي التهيئة
  MyAuthProvider() {
    _initUserData();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  // دالة لجلب بيانات المستخدم إذا كان مسجلاً دخول بالفعل
  Future<void> _initUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DataSnapshot snapshot = await _dbRef.child("reader").child(user.uid).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        _userName = data['name'] as String? ?? "مستخدم";
        // يمكنك قراءة بيانات التقييم إن رغبت:
        String rate = data['rate'] as String? ?? "0";
        print("المتوسط الحالي: $rate");
        notifyListeners();
      }
    }
  }
  Future<String?> signUp(String email, String password , String phone , String name) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      String user_id = user!.uid;
      InsertUserData(user_id, name, email, phone, "0");
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(); // إرسال التحقق للبريد
      }

      notifyListeners(); // تحديث الواجهة
      return null;
    } on FirebaseAuthException catch (e) {
      return 'البريد الالكتروني مستخدم بالفعل ';
    }
  }

  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload(); // تحديث بيانات المستخدم
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      User? user = userCredential.user;

      // التحقق من التحقق من البريد الإلكتروني
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return 'يرجى التحقق من بريدك الإلكتروني قبل تسجيل الدخول. تم إرسال رابط التحقق إلى بريدك.';
      }

      // التحقق من حالة الحساب في قاعدة البيانات
      if (user != null) {
        DataSnapshot snapshot = await _dbRef.child("reader").child(user.uid).get();
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          _userName = data['name'] as String? ?? "مستخدم";
          if (data['active'] != true) {
            await signOut(); // إلغاء تسجيل الدخول
            return 'تم إيقاف تفعيل الحساب';
          }
        }
      }

      notifyListeners(); // تحديث الواجهة بعد تسجيل الدخول
      return null;
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.code}');
      switch (e.code) {
        case 'invalid-credential':
          return 'البريد الالكتروني او كلمة المرور غير صحيح';
        case 'wrong-password':
          return 'كلمة المرور غير صحيحة. حاول مرة أخرى.';
        case 'user-disabled':
          return 'حسابك غير مفعل، يرجى التواصل مع الدعم.';
        case 'too-many-requests':
          return 'تم حظر الحساب مؤقتًا بسبب محاولات متكررة. حاول لاحقًا.';

        default:
          return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
      }
    }
  }


  Future<String?> adminSignIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      User? user = userCredential.user;

      // التحقق من حالة الحساب في قاعدة البيانات
      if (user != null) {
        DataSnapshot snapshot = await _dbRef.child("admin").child(user.uid).get();
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;

        }
      }

      notifyListeners(); // تحديث الواجهة بعد تسجيل الدخول
      return null;
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.code}');
      switch (e.code) {
        case 'invalid-credential':
          return 'البريد الالكتروني او كلمة المرور غير صحيح';
        case 'wrong-password':
          return 'كلمة المرور غير صحيحة. حاول مرة أخرى.';
        case 'user-disabled':
          return 'حسابك غير مفعل، يرجى التواصل مع الدعم.';
        case 'too-many-requests':
          return 'تم حظر الحساب مؤقتًا بسبب محاولات متكررة. حاول لاحقًا.';

        default:
          return 'حدث خطأ غير متوقع, تأكد من اتصال الشبكة و حاول مرة أخرى.';
      }
    }
  }






  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // تم إرسال الرابط بنجاح
    } on FirebaseAuthException catch (e) {
      print('⚠️ خطأ أثناء إعادة تعيين كلمة المرور: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          return 'البريد الإلكتروني غير مسجل في النظام.';
        case 'invalid-email':
          return 'يرجى إدخال بريد إلكتروني صحيح.';
        default:
          return 'حدث خطأ أثناء محاولة إعادة تعيين كلمة المرور.';
      }
    }
  }


  Future<void> InsertUserData(String uid, String name, String email,
      String phone, String rate) async {
    await _dbRef.child("reader").child(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'rate': rate,
      'ratings': {   // قسم خاص بالتقييمات
        'sum': 0,    // مجموع التقييمات
        'count': 0,  // عدد التقييمات
      },
      'active': true, // إضافة الحقل وتعيينه افتراضيًا
    });
    print("تم التسجيل وتخزين بيانات المستخدم بنجاح");
  }



  Future<void> signOut() async {
    await _auth.signOut();
    _userName = '';
    notifyListeners();
  }
}
