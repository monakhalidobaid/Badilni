import 'package:badilni_v1/style/styled_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/my_auth_provider.dart';
import '../../widgets/custom_appbar.dart';
import '../profile_screen.dart';
import 'dart:io';


class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  _EditProfileState createState() => _EditProfileState();

}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String userEmail = ""; // سيتم جلبه من قاعدة البيانات
  String userName='';
  String userPhone='';

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getProfileData();// جلب البيانات الحالية من قاعدة البيانات
  }

  Future<void> getProfileData() async{
    final snapshot= await _dbRef.child('reader').child(auth.currentUser!.uid).get();
    setState(() {
      userName= snapshot.child("name").value as String? ?? '';
      userPhone = snapshot.child("phone").value  as String? ?? '';
      userEmail = snapshot.child("email").value  as String? ?? '';
      // ضبط الحقول النصية بالقيم الحالية
      nameController.text = userName;
      phoneController.text = userPhone;


    });
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضمان أن المحتوى من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: CustomAppBar(
          title: "تعديل الملف الشخصي",
        ),

        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 115,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(width: 4, color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 2,
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // اسم المستخدم والبريد الإلكتروني
                Text(
                  userName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  userEmail,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),

                // نموذج تعديل البيانات
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTextField(
                        nameController,
                        "اسم المستخدم",
                            (value) {
                          if (value == null || value.isEmpty) {
                            return "يرجى إدخال اسم المستخدم";
                          }
                          else if (value.length < 2) {
                            return "يجب أن يكون الاسم مكونًا من حرفين على الأقل";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      buildTextField(
                        phoneController,
                        "رقم الهاتف",
                            (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال رقم الجوال';
                          }
                          // التعبير النظامي يسمح فقط بالأرقام بصيغة دولية مع +966 أو 966
                          final phoneRegex = RegExp(r'^(?:\+966|966)5\d{8}$');
                          if (!phoneRegex.hasMatch(value)) {
                            return 'يرجى إدخال رقم جوال بصيغة دولية (مثال: +966550037776)';
                          }
                          return null;
                        },

                      ),

                      SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await updateProfileData(
                                    auth.currentUser!.uid,
                                    nameController.text,
                                    phoneController.text
                                );

                                // 2) حدّث المزود حتى ينعكس الاسم فوراً في HomeScreen
                                Provider.of<MyAuthProvider>(context, listen: false)
                                    .setUserName(nameController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم تحديث معلومات المستخدم'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context, true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:Color(0xC8B7F3EC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,horizontal: 42,
                              ),
                            ),
                            child: HeadlineMedium('حفظ التغيرات ',
                             ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:Color(0xC8B7F3EC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,horizontal: 60,
                              ),
                            ),
                            child:const  HeadlineMedium(
                              'الغاء',
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  /// دالة لإنشاء حقل نص موحد لتقليل التكرار
  Widget buildTextField(TextEditingController controller,
      String label,
      String? Function(String?)? validator,
      )
  {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: label == "رقم الهاتف" ? TextInputType.phone : TextInputType.text,
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderSide:const BorderSide(color: Color(0xC8B7F3EC), width: 1.5), // لون الحدود
          borderRadius: BorderRadius.circular(12), // تحديد الزوايا المدورة
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xC8B7F3EC), width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      //  onChanged: onChanged,
    );
  }

  // دالة لتحديث البيانات

  Future<void> updateProfileData( String id,String name,String phone) async{
    Map<String, dynamic> updates = {};

    if (name != null) {
      updates['name'] = name;
    }
    if (phone != null) {
      updates['phone'] = phone;
    }
    if (updates.isNotEmpty) {
      await FirebaseDatabase.instance.ref('reader').child(id).update(updates);
    }
  }
}
