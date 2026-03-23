import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../style/styled_text.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_appbar.dart';
import '../reader/add_book_screen.dart';

class AdminEditPrintedBook extends StatefulWidget {
  final String book_id;

  const AdminEditPrintedBook({super.key, required this.book_id});

  @override
  State<AdminEditPrintedBook> createState() => _AdminEditPrintedBookState();
}

class _AdminEditPrintedBookState extends State<AdminEditPrintedBook> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final ImagePicker _picker = ImagePicker();

  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController conditionController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  File? _selectedImage;
  String imageUrl = '';
  bool _isLoading = false;
  bool _isImageSelected = true;

  String bookTitle = "";
  String bookAuthor = "";
  String bookCategory = "";
  String bookCondition = "";
  String bookDescription = "";
  String bookImage = "";
  String bookState = "";

  // تعريف قائمة الخيارات بناءً على enum
  ExchangeStatus? selectedExchangeStatus;


  @override
  void initState() {
    super.initState();
    fetchCurrentBook();
  }

  String url_img = "";
  String Uid = "";

  Future<void> fetchCurrentBook() async {
    final snapshot =
    await _dbRef.child('Printed_books').child(widget.book_id).get();
    setState(() {
      titleController.text = snapshot.child("title").value as String? ?? '';
      authorController.text = snapshot.child("author").value as String? ?? '';
      categoryController.text = snapshot.child("genre").value as String? ?? '';
      conditionController.text =
          snapshot.child("condition").value as String? ?? '';
      descriptionController.text =
          snapshot.child("description").value as String? ?? '';
      Uid = snapshot.child("uid").value as String? ?? '';
      String value = snapshot.child("state").value as String? ?? '';
      if (value == "notAvailable")
        selectedExchangeStatus = ExchangeStatus.notAvailable;
      else if (value == "exchangeWithoutReturn")
        selectedExchangeStatus = ExchangeStatus.exchangeWithoutReturn;
      else
        selectedExchangeStatus = ExchangeStatus.exchangeWithReturn;
      url_img = snapshot.child("image").value as String? ?? '';
    });
  }

  final DatabaseReference _dbRefUpdate = FirebaseDatabase.instance.ref();
  Future<void> updateBook() async {
    await _dbRefUpdate.child("Printed_books").child(widget.book_id).set({
      'uid': Uid,
      'title': titleController.text,
      'author': authorController.text,
      'genre': categoryController.text,
      'description': descriptionController.text,
      'image': url_img,
      'condition': conditionController.text,
      'state': selectedExchangeStatus!.name
    });
    print("تم التسجيل وتخزين بيانات المستخدم بنجاح");
  }

  /// دالة لحذف الكتاب من قاعدة البيانات
  Future<void> deleteBook() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _dbRef.child("Printed_books").child(widget.book_id).remove();
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف الكتاب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء الحذف ❌'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لضمان أن المحتوى من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: "تعديل الكتاب",
        ),
        // استخدم Stack لتغليف المحتوى وعرض مؤشر التحميل فوقه
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(11.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          // قسم اختيار الصورة
                          GestureDetector(
                            onTap: pickImageFromGallery,
                            child: Container(
                              width: 150,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xC8B7F3EC),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _selectedImage != null
                                    ? Image.file(
                                  _selectedImage!,
                                  width: 150,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                                    : Image.network(
                                  url_img,
                                  width: 150,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null)
                                      return child;
                                    return Center(
                                        child:
                                        CircularProgressIndicator());
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return const Icon(Icons.error,
                                        size: 40, color: Colors.red);
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          // تنبيه تحت الصورة
                          Visibility(
                            visible: !_isImageSelected,
                            child: const Text(
                              "يرجى اختيار صورة للكتاب",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      buildTextField(titleController, "عنوان الكتاب",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "الرجاء إدخال عنوان الكتاب";
                            }
                            return null;
                          }, onChanged: (val) {
                            setState(() {
                              bookTitle = val;
                            });
                          }),
                      const SizedBox(height: 8),
                      buildTextField(authorController, "اسم المؤلف",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "الرجاء إدخال اسم المؤلف";
                            }
                            return null;
                          }, onChanged: (val) {
                            setState(() {
                              bookAuthor = val;
                            });
                          }),
                      const SizedBox(height: 8),
                      buildTextField(categoryController, "التصنيف",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "الرجاء إدخال التصنيف";
                            }
                            return null;
                          }, onChanged: (val) {
                            setState(() {
                              bookCategory = val;
                            });
                          }),
                      const SizedBox(height: 8),
                      buildTextField(conditionController, "حالة الكتاب",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "الرجاء إدخال حالة الكتاب";
                            }
                            return null;
                          }, onChanged: (val) {
                            setState(() {
                              bookCondition = val;
                            });
                          }),
                      const SizedBox(height: 3),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Color(0xC8B7F3EC), width: 1.5),
                        ),
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Column(
                          children: [
                            const Text("حالة التبادل",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
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
                      buildTextField(descriptionController, "نبذة",
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "";
                            }
                            return null;
                          }, onChanged: (val) {
                            setState(() {
                              bookDescription = val;
                            });
                          }),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  if (_selectedImage != null) {
                                    await imageUpload();
                                  }
                                  await updateBook();
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                      Text('تم تحديث البيانات بنجاح'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                      Text('حدث خطأ أثناء التحديث ❌'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xC8B7F3EC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 36),
                            ),
                            child: const HeadlineMedium('حفظ التغيرات'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // عرض نافذة تأكيد الحذف
                              bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return  Directionality(
                                      textDirection: TextDirection.rtl, // لجعل النص من اليمين إلى اليسار
                                      child: AlertDialog(
                                        backgroundColor: Colors.white, // تغيير لون الخلفية

                                        title: const Text('تأكيد الحذف',style: TextStyle(
                                          color: Colors.black, // تغيير لون النص في العنوان
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),),
                                    content: const Text('هل تريد حذف هذا الكتاب؟',style: TextStyle(
                                      color: Colors.black, // تغيير لون النص في العنوان
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    )),
                                        actions: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center, // توسيط الأزرار
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.primaryColor,
                                                  textStyle: const TextStyle(fontSize: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                    horizontal: 28.0,
                                                  ),
                                                  minimumSize: Size.zero,
                                                  visualDensity: VisualDensity.compact,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop(false);
                                                },
                                                child: const BodySmall('إلغاء'),
                                              ),
                                              const SizedBox(width: 10), // مسافة بين الزرين
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppTheme.primaryColor,
                                                  textStyle: const TextStyle(fontSize: 12),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 11.0,
                                                    horizontal: 28.0,
                                                  ),
                                                  minimumSize: Size.zero,
                                                  visualDensity: VisualDensity.compact,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop(true);
                                                },
                                                child: const BodySmall('موافق'),
                                              ),
                                            ],
                                          ),
                                        ],
                                  ));
                                },
                              );

                              if (confirm == true) {
                                // إذا اختار المستخدم "موافق" يتم تنفيذ الحذف
                                await deleteBook();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xC8B7F3EC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 60,
                              ),
                            ),
                            child: const HeadlineMedium('حذف'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // مؤشر التحميل يغطي الصفحة كاملة عند تفعيل _isLoading
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// دالة لإنشاء حقل نص موحد لتقليل التكرار
  Widget buildTextField(TextEditingController controller, String label,
      {int maxLines = 1,
        required String? Function(String?)? validator,
        required Function(String) onChanged}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'هذا الحقل مطلوب';
        } else if (!RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(value)) {
          return 'يُسمح فقط بإدخال الأحرف العربية والإنجليزية';
        }
        return null;
      },
      style: TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xC8B7F3EC), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xC8B7F3EC), width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      onChanged: onChanged,
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$')),
      ],
    );
  }

  Future<void> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// دالة لإنشاء خيارات التبادل الموحدة
  Widget buildExchangeOption({
    required String title,
    required ExchangeStatus value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      title: Text(title, style: TextStyle(fontSize: 12)),
      leading: Radio<ExchangeStatus>(
        value: value,
        groupValue: selectedExchangeStatus,
        onChanged: (ExchangeStatus? newValue) {
          setState(() {
            selectedExchangeStatus = newValue;
          });
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // دالة رفع الصورة إلى Supabase
  Future<String> imageUpload() async {
    print("upload");
    final bytes = await _selectedImage?.readAsBytes();
    final fileName =
        "image_${DateTime.now().millisecondsSinceEpoch}" + ".png";

    await Supabase.instance.client.storage
        .from("image")
        .uploadBinary(fileName, bytes!);

    final urlResponse = Supabase.instance.client.storage
        .from('image')
        .getPublicUrl('$fileName');

    url_img = urlResponse;

    print('image_url:$url_img');

    return url_img;
  }
}
