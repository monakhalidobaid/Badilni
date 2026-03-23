import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data_models/printedBook.dart';
import '../../style/styled_text.dart';
import '../../widgets/custom_appbar.dart';

class AddEbookPage extends StatefulWidget {
  const AddEbookPage({super.key});

  @override
  AddEbookPageState createState() => AddEbookPageState();
}

class AddEbookPageState extends State<AddEbookPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _fileSizeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  File? _selectedImage;
  File? _selectedPdf;
  String url_image = "";
  String url_PDF = "";
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isImageSelected = true;
  bool _isPdfSelected = true;

  String convertArabicToEnglishNumbers(String input) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    for (int i = 0; i < arabicNumbers.length; i++) {
      input = input.replaceAll(arabicNumbers[i], englishNumbers[i]);
    }
    input = input.replaceAll('٫', '.'); // النقطة العشرية العربية
    return input;
  }

  Future<void> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل اختيار الصورة: $e')),
      );
    }
  }

  Future<void> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        setState(() {
          _selectedPdf = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل اختيار الملف: $e')),
      );
    }
  }

  Future<String> uploadPDF() async {
    final byte = await _selectedPdf?.readAsBytes();
    final fileName = "PDF_${DateTime.now().millisecondsSinceEpoch}.pdf";

    await Supabase.instance.client.storage
        .from("image")
        .uploadBinary(fileName, byte!);

    final publicUrlResponse = Supabase.instance.client.storage
        .from('image')
        .getPublicUrl('$fileName');
    url_PDF = publicUrlResponse;

    return url_PDF;
  }

  Future<String> uploadImage() async {
    final byte = await _selectedImage?.readAsBytes();
    final fileName = "image_${DateTime.now().millisecondsSinceEpoch}.png";

    await Supabase.instance.client.storage
        .from("image")
        .uploadBinary(fileName, byte!);

    final publicUrlResponse = Supabase.instance.client.storage
        .from('image')
        .getPublicUrl('$fileName');
    url_image = publicUrlResponse;

    return url_image;
  }

  Future<void> _validateAndSubmit() async {
    setState(() {
      _isImageSelected = _selectedImage != null;
      _isPdfSelected = _selectedPdf != null;
    });

    if (!_formKey.currentState!.validate()) return;
    if (!_isImageSelected || !_isPdfSelected) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var imageUrl = await uploadImage();
      var pdfUrl = await uploadPDF();

      await insertEbook(
        '',
        _titleController.text,
        _authorController.text,
        _categoryController.text,
        imageUrl,
        _descriptionController.text,
        _priceController.text,
        _fileSizeController.text,
        pdfUrl,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة الكتاب بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: "إضافة كتاب إلكتروني",
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
// صورة الكتاب
                  Column(
                    children: [
                      GestureDetector(
                        onTap: pickImageFromGallery,
                        child: _selectedImage == null
                            ? Container(
                                width: 150,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isImageSelected
                                        ? const Color(0xC8B7F3EC)
                                        : Colors.red,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.black54,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImage!,
                                  width: 150,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      const SizedBox(height: 5),
                      Visibility(
                        visible: !_isImageSelected,
                        child: const Text(
                          "يرجى اختيار صورة للكتاب",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

// حقول الإدخال
                  buildTextField(
                    controller: _titleController,
                    label: "عنوان الكتاب",
                    hint: "",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال عنوان الكتاب";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  buildTextField(
                    controller: _authorController,
                    label: "اسم المؤلف",
                    hint: "",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال اسم المؤلف";
                      }
                      // تحقق من وجود أرقام عربية أو إنجليزية
                      if (RegExp(r'[0-9\u0660-\u0669]').hasMatch(value)) {
                        return "يجب أن يحتوي الاسم على حروف فقط بدون أرقام";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),
                  buildTextField(
                    controller: _categoryController,
                    label: "التصنيف",
                    hint: "رعب, غموض, خيالي",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال التصنيف";
                      }
                      if (RegExp(r'[0-9\u0660-\u0669]').hasMatch(value)) {
                        return "يجب أن يحتوي التصنيف على حروف فقط بدون أرقام";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  buildTextField(
                    controller: _fileSizeController,
                    label: "حجم الملف (MB)",
                    hint: "مثال: 5 أو 5.2",
                    keyboardType: TextInputType.number,
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
                  ),

                  const SizedBox(height: 12),
                  buildTextField(
                    controller: _priceController,
                    label: "السعر (ر.س)",
                    hint: "مثال: 25 أو 25.5",
                    keyboardType: TextInputType.number,
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
                  ),

                  const SizedBox(height: 12),
                  buildTextField(
                    controller: _descriptionController,
                    label: "نبذة عن الكتاب",
                    hint: "وصف مختصر للكتاب",
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "الرجاء إدخال نبذة عن الكتاب";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

// ملف PDF - التصميم الجديد
                  Column(
                    children: [
                      GestureDetector(
                        onTap: pickPdfFile,
                        child: Container(
                          width: 380, // عرض أصغر
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedPdf == null
                                ? Colors.grey[200] // رمادي عند عدم الاختيار
                                : const Color(0xFFE8F5E9),
                            // أخضر فاتح عند الاختيار
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedPdf == null
                                  ? Colors.grey[400]! // رمادي عند عدم الاختيار
                                  : const Color(0xFF4CAF50),
                              // أخضر عند الاختيار
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                size: 36,
                                color: _selectedPdf == null
                                    ? Colors.grey[600] // رمادي غامق
                                    : const Color(0xFF2E7D32), // أخضر غامق
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedPdf == null
                                    ? "اختر ملف الكتاب PDF"
                                    : "تم اختيار الملف",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedPdf == null
                                      ? Colors.grey[700]
                                      : const Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_selectedPdf != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _selectedPdf!.path.split('/').last,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Visibility(
                        visible: !_isPdfSelected,
                        child: const Text(
                          "يجب اختيار ملف PDF للكتاب",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

// أزرار الإضافة والإلغاء
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _validateAndSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xC8B7F3EC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 60,
                                ),
                              ),
                              child: const HeadlineMedium('إضافة'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xC8B7F3EC),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 60,
                                ),
                              ),
                              child: const HeadlineMedium('إلغاء'),
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

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xC8B7F3EC), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xC8B7F3EC), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
      ),
    );
  }

  Future<void> insertEbook(
    String uid,
    String title,
    String author,
    String genre,
    String image,
    String description,
    String price,
    String size,
    String pdfUrl,
  ) async {
    final newBookRef = _dbRef.child("E_book").push();
    final String? generatedKey = newBookRef.key;

    await newBookRef.set({
      'uid': generatedKey ?? '',
      'title': title,
      'author': author,
      'genre': genre,
      'image': image,
      'description': description,
      'price': price,
      'size': size,
      'pdf_url': pdfUrl,
      'status': true,
    });

    debugPrint("تم إضافة كتاب إلكتروني بنجاح");
  }
}
