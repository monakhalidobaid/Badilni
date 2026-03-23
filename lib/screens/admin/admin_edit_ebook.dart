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
import 'add_ebook_screen.dart';
class AdminEditEbook extends StatefulWidget {
  final String book_id;

  const AdminEditEbook({super.key, required this.book_id});

  @override
  State<AdminEditEbook> createState() => _AdminEditEbookState();
}

class _AdminEditEbookState extends State<AdminEditEbook> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final ImagePicker _picker = ImagePicker();

  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController fileSizeController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  File? _selectedImage;
  String imageUrl = '';
  bool _isLoading = false;
  bool _isImageSelected = true;


  String bookTitle = "";
  String bookAuthor = "";
  String bookCategory = "";
  String pdf_url = "";
  String booksize = "";
  String bookprice = "";
  String bookDescription = "";
  String bookImage = "";

  String convertArabicToEnglishNumbers(String input) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    for (int i = 0; i < arabicNumbers.length; i++) {
      input = input.replaceAll(arabicNumbers[i], englishNumbers[i]);
    }
    input = input.replaceAll('٫', '.'); // النقطة العشرية العربية
    return input;
  }

  @override
  void initState() {
    super.initState();
    fetchCurrentBook();
  }

  String url_img = "";
  String Uid = "";

  Future<void> fetchCurrentBook() async {
    final snapshot =
    await _dbRef.child('E_book').child(widget.book_id).get();
    setState(() {
      titleController.text = snapshot.child("title").value as String? ?? '';
      authorController.text = snapshot.child("author").value as String? ?? '';
      categoryController.text = snapshot.child("genre").value as String? ?? '';
      fileSizeController.text = snapshot.child("size").value as String? ?? '';
      priceController.text = snapshot.child("price").value as String? ?? '';
      descriptionController.text =
          snapshot.child("description").value as String? ?? '';
      Uid = snapshot.child("uid").value as String? ?? '';
      url_img = snapshot.child("image").value as String? ?? '';
      pdf_url  = snapshot.child("pdf_url").value as String? ?? '';

    });
  }

  final DatabaseReference _dbRefUpdate = FirebaseDatabase.instance.ref();
  Future<void> updateBook() async {
    await _dbRefUpdate.child("E_book").child(widget.book_id).update({
      'uid': Uid,
      'title': titleController.text,
      'author': authorController.text,
      'genre': categoryController.text,
      'description': descriptionController.text,
      'image': url_img,
      'size': fileSizeController.text,
      'price': priceController.text,
      'pdf_url':pdf_url
    });
    print("تم التسجيل وتخزين بيانات المستخدم بنجاح");
  }

  /// دالة لحذف الكتاب من قاعدة البيانات
  Future<void> deleteBook() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await _dbRef.child("E_book").child(widget.book_id).remove();
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
          title: "تعديل الكتاب الإلكتروني",
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
                            // تحقق من وجود أرقام عربية أو إنجليزية
                            if (RegExp(r'[0-9\u0660-\u0669]').hasMatch(value)) {
                              return "يجب أن يحتوي الاسم على حروف فقط بدون أرقام";
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
                            if (RegExp(r'[0-9\u0660-\u0669]').hasMatch(value)) {
                              return "يجب أن يحتوي التصنيف على حروف فقط بدون أرقام";
                            }
                            return null;
                          }, onChanged: (val) {
                            setState(() {
                              bookCategory = val;
                            });
                          }),
                      const SizedBox(height: 8),
                      buildTextField(fileSizeController, "حجم الكتاب",

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "الرجاء إدخال حجم الملف";
                            }
                            final normalized = convertArabicToEnglishNumbers(value);
                            if (double.tryParse(normalized) == null) {
                              return "الرجاء إدخال رقم صالح (مثال: ٥ أو ٥٫٢)";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() {
                              booksize = val;
                            });
                          }),
                      const SizedBox(height: 8),
                      buildTextField(priceController, "سعر الكتاب",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "الرجاء إدخال السعر";
                            }
                            final normalized = convertArabicToEnglishNumbers(value);
                            if (double.tryParse(normalized) == null) {
                              return "الرجاء إدخال رقم صالح (مثال: ٢٥ أو ٢٥٫٥)";
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() {
                              bookprice = val;
                            });
                          }),

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
                        children: [
                          Expanded(
                            child: ElevatedButton(
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
                                        content: Text('تم تحديث البيانات بنجاح'),
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
                                        content: Text('حدث خطأ أثناء التحديث ❌'),
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
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                              ),
                              child: const HeadlineMedium('حفظ التغيرات'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                bool? confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: const Text(
                                            'تأكيد الحذف',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          content: const Text(
                                            'هل تريد حذف هذا الكتاب؟',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
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
                                                const SizedBox(width: 10),
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
                                  await deleteBook();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xC8B7F3EC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 60),
                              ),
                              child: const HeadlineMedium('حذف'),
                            ),
                          ),
                        ],
                      )

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
  Widget buildTextField(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
        required String? Function(String?)? validator,
        required Function(String) onChanged,
        bool isNumeric = false,
        bool allowMultilingual = false,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator, // استخدم الـ validator الخارجي مباشرة
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xC8B7F3EC), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xC8B7F3EC), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
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





