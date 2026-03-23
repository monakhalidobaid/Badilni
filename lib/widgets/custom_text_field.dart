import 'package:flutter/material.dart';
//
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true; // حالة إخفاء النص

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 300, // تحديد العرض
        height: 40,  // تحديد الطول
        child: TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword
          ? _obscureText
          : false, // إخفاء النص إذا كان حقل كلمة مرور
      keyboardType: widget.keyboardType,
          textAlign: TextAlign.right, // جعل النص داخل الحقل يبدأ من اليمين
          textDirection: TextDirection.rtl, // تغيير اتجاه الكتابة إلى اليمين
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xAD46CCBD), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
            suffixIcon: widget.isPassword
                ? Directionality(
              textDirection: TextDirection.ltr,
              child: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            )
                : null,
          ),

          validator: widget.validator,
    ),);
  }
}
