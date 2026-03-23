import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final Function() onClear;
  final String hintText; // نص البحث الافتراضي قابل للتعديل

  const CustomSearchField({
    required this.controller,
    required this.onSearch,
    required this.onClear,
    this.hintText = "بحث",
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40, // جعل الحقل أنحف
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey[400]!,
          width: 1, // لون الحدود باهت
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearch, // يتم استدعاؤه عند الكتابة
        textAlign: TextAlign.right, // محاذاة النص لليمين
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.black),
            onPressed: () {
              controller.clear();
              onSearch('');
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 0.1,
            horizontal: 16,
          ), // تقليل الحشوة الداخلية
        ),
      ),
    );
  }
}
