import 'dart:io';
import 'package:badilni_v1/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data_models/printedBook.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

import '../../style/styled_text.dart';
import '../../widgets/custom_appbar.dart';

// تعريف الأنواع الخاصة بخيارات التبادل
enum ExchangeStatus { exchangeWithReturn, exchangeWithoutReturn, notAvailable }

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});
  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  // مفاتيح النماذج للتحقق من صحة المدخلات
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // لاتصال بقاعدة البيانات
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;

  // المتغيرات التي تخزن بيانات الكتاب
  String bookName = "";
  String authorName = "";
  String classification = "";
  String bookStatus = "";
  String bookDescription = "";

  // متغير لتحديد حالة التبادل المحددة، افتراضيًا أول خيار
  ExchangeStatus? _exchangeStatus = ExchangeStatus.exchangeWithReturn;

  // Controllers لحقول النص
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController conditionController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? _selectedImage;
  String image_url='';
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isImageSelected = true;


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضمان أن المحتوى من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: "اضافه الكتاب",
        ),


        body: Padding(
          padding: const EdgeInsets.all(11.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      // قسم اختيار الصورة
                      GestureDetector(
                        onTap: pickImageFromGallery,
                        child: _selectedImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          // زوايا دائرية
                          child: Image.file(
                            _selectedImage!,
                            width: 150,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Container(
                          width: 150,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isImageSelected
                                  ? Color(0xC8B7F3EC)
                                  : Colors.red,
                              width: 1.5,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              width: 150,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),
                      // مسافة صغيرة بين الصورة والتنبيه

                      // تنبيه تحت الصورة مباشرة
                      Visibility(
                        visible: !_isImageSelected,
                        // يظهر فقط إذا لم يتم اختيار صورة
                        child: const Text(
                          "يرجى اختيار صورة للكتاب",
                          style: TextStyle(color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  buildTextField(
                    controller: titleController,
                    label: "عنوان الكتاب",
                    hint: "",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال عنوان الكتاب";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        bookName = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  buildTextField(
                    controller: authorController,
                    label: "اسم المؤلف",
                    hint: "",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال اسم المؤلف";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        authorName = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  buildTextField(
                    controller: categoryController,
                    label: "التصنيف",
                    hint: "رعب, غموض, خيالي",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال التصنيف";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        classification = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  buildTextField(
                    controller: conditionController,
                    label: "حالة الكتاب",
                    hint: "مثل: صفحات الكتاب مطويه",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال حالة الكتاب";
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        bookStatus = val;
                      });
                    },
                  ),
                  const SizedBox(height: 3),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      //color: Colors.white, // يمكنك تخصيص لون الخلفية حسب الحاجة
                      border: Border.all(color: Color(0xC8B7F3EC), width: 1.5),
                      // تحديد حدود الصندوق
                    ),
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.symmetric(vertical: 5),

                    child:Column(
                      children: [
                        const Text("حالة التبادل",style: TextStyle (fontWeight: FontWeight.bold,fontSize: 14,)),
                        buildExchangeOption(
                          title: "تبادل مع ارجاع خلال 60 يوم",
                          value: ExchangeStatus.exchangeWithReturn,
                        ),
                        buildExchangeOption(
                          title: "تبادل بدون ارجاع",
                          value: ExchangeStatus.exchangeWithoutReturn,
                        ),
                        buildExchangeOption(
                          title: "غير متاح لتبادل",
                          value: ExchangeStatus.notAvailable,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // قسم: وصف الكتاب
                  buildTextField(
                    controller: descriptionController,
                    maxLines: 5,
                    label: "نبذه",
                    hint: "نبذه عن الكتاب",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "";
                      }
                      return null;
                    },

                    onChanged: (val) {
                      setState(() {
                        bookDescription = val;
                      });
                    },
                  ),

                  const SizedBox(height: 50),
                  // عرض مؤشر التحميل إذا كانت العملية جارية
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                  // قسم: أزرار الإضافة والإلغاء
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isImageSelected = _selectedImage != null; // تحديث الحالة بناءً على اختيار الصورة
                          });


                          if (_formKey.currentState!.validate()) {
                            if (_selectedImage == null) {
                              return; // إيقاف العملية إذا لم يتم اختيار صورة
                            }

                            setState(() {
                              _isLoading = true; // عرض مؤشر التحميل
                            });

                            var image = await  imageUpload();
                            // **تم التعديل هنا:** إنشاء كائن Printedbook جديد باستخدام البيانات المدخلة من المستخدم
                            Printedbook newBook = Printedbook(
                              title: titleController.text,
                              author: authorController.text,
                              genre: categoryController.text,
                              image:
                              image_url, // يمكنك تعديلها لاحقاً لتستخدم الصورة المختارة من _selectedImage
                              status: bookStatus,
                              description: descriptionController.text,
                              condition: conditionController.text,
                            );
                            // استدعاء دالة الإدخال على الكائن الجديد
                            await newBook.insertPrintedBook(
                              auth.currentUser!.uid,
                              titleController.text,
                              authorController.text,
                              categoryController.text,
                              image_url, // يمكنك تعديلها لاحقاً لتستخدم الرابط الصحيح للصورة
                              descriptionController.text,
                              conditionController.text,
                              _exchangeStatus!.name,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تمت إضافة الكتاب بنجاح'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            setState(() {
                              _isLoading = false; // إخفاء مؤشر التحميل عند انتهاء العملية
                            });
                            Navigator.pop(context, true);

                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:Color(0xC8B7F3EC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,horizontal: 60,
                          ),
                        ),
                        child: const  HeadlineMedium('اضافه',),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم إلغاء العملية'),
                            ),
                          );
                          Navigator.pop(context);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor:Color(0xC8B7F3EC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,horizontal: 60,
                          ),
                        ),
                        child: const  HeadlineMedium('إلغاء'),
                      ),
                    ],
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }










  /// دالة لإنشاء حقل نص موحد لتقليل التكرار
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    required String? Function(String?)? validator,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'هذا الحقل مطلوب'; // تنبيه عند ترك الحقل فارغًا
        } else if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(value)) {
          return 'يُسمح فقط بإدخال الأحرف العربية والإنجليزية'; // تنبيه عند إدخال أرقام أو رموز
        }
        return null;
      },
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xC8B7F3EC), width: 1.5), // لون الحدود
          borderRadius: BorderRadius.circular(12), // تحديد الزوايا المدورة
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xC8B7F3EC), width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$')), // السماح فقط بالأحرف العربية والإنجليزية
      ],
    );

  }

  /// دالة لإنشاء خيارات التبادل الموحدة
  Widget buildExchangeOption({

    required String title,
    required ExchangeStatus value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8), // تقليص المسافة داخل ListTile

      title: Text(title, style: TextStyle(fontSize: 12)),
      leading: Radio<ExchangeStatus>(
        value: value,
        groupValue: _exchangeStatus,
        onChanged: (ExchangeStatus? newValue) {
          setState(() {
            _exchangeStatus = newValue;
          });
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // تصغير حجم المنطقة القابلة للنقر
      ),
    );
  }

  /// دالة اختيار صورة من المعرض
  Future<void> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          // imageUpload();
        });
      }
    } catch (e) {
      // تحقق مما إذا كان العنصر لا يزال مثبتًا قبل استخدام c?ontext
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل اختيار الصورة: $e')),
      );
    }
  }


  //داله لاضافه الصور في الفايربيس من السوبابيس
  Future<String> imageUpload() async{
    print("upload");
    final bytes= await _selectedImage?.readAsBytes();
    final fileName="image_${DateTime.now().millisecondsSinceEpoch}"+".png";

    final response=await Supabase.instance.client.storage.from("image")
        .uploadBinary(fileName, bytes!);

    final urlResponse= Supabase.instance.client.storage.from('image')
        .getPublicUrl('$fileName');

    image_url= urlResponse;

    print('image_url:$image_url');

    return image_url;
  }
}


