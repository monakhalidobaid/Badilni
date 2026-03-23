// فئة Reader (المستخدم العادي)
import 'package:badilni_v1/data_models/user.dart';
class Reader extends User {
  double rating;
  String phoneNumber;
  bool active; // حقل لتحديد ما إذا كان الحساب مفعل أم لا
//
  Reader({
    required String uid,
    required String email,
    required String username,
    required this.rating,
    required this.phoneNumber,
    this.active = true, // القيمة الافتراضية: الحساب مفعل
  }) : super(
    uid: uid,
    email: email,
    username: username,
  );
}
