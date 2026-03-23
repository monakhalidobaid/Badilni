import 'package:badilni_v1/data_models/reader.dart';
import 'package:badilni_v1/data_models/user.dart';
import 'package:firebase_database/firebase_database.dart';
//
class Admin extends User {
  Admin({
    required String uid,
    required String email,
    required String username,
  }) : super(
    uid: uid,
    email: email,
    username: username,
  );

  // دالة لجلب بيانات المستخدمين من Firebase
  Future<List<Reader>> fetchReaders() async {
    List<Reader> readers = [];
    DatabaseReference ref = FirebaseDatabase.instance.ref("reader");
    try {
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        //ايش يوزر داتا؟
        data.forEach((uid, userData) {

          // استبعاد المستخدم الذي يحمل المعرف المحدد
          if (uid == '3aVI843uvzddgF4lVG9wyGZTMKw2'|| uid=="fXDq1oo2TPXFvA6nqnmqp5OetIE3" ) {
            return; // تخطي هذا المستخدم
          }

          // تأكد من قراءة الحقول المطلوبة
          bool isActive = userData['active'] ?? true;
          if (isActive) {
            var reader = Reader(
              uid: userData['uid'] ?? "",
              email: userData['email'] ?? "",
              username: userData['name'] ?? "",
              // يجب الاطلاع عليه لاحقا مع الدكتور
              rating: double.tryParse(userData['rate']?.toString() ?? "0") ?? 0.0,
              phoneNumber: userData['phone'] ?? "",
              active: isActive,
            );
            readers.add(reader);
          }
        });
      }
    } catch (e) {
      print("Error fetching readers: $e");
    }
    return readers;
  }

  // دالة لتعطيل حساب مستخدم معين
  Future<void> deleteReaderAccount(String uid) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref("reader/$uid");
    try {
      await userRef.update({'active': false});
      print("Account disabled successfully.");
    } catch (e) {
      print("Error disabling account: $e");
    }
  }
}
