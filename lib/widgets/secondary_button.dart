import 'package:badilni_v1/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../style/styled_text.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:AppTheme.primaryColor, // لون البوردر
          textStyle: const TextStyle(fontSize: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // زوايا خفيفة الانحناء
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 11.0,
            horizontal: 28.0,
          ), // حشوة صغيرة لجعل الزر أنحف
          minimumSize: Size.zero,                // السماح للزر بأن يصبح صغيراً جداً
          visualDensity: VisualDensity.compact,  // تقليل المساحات الافتراضية
        ),
        onPressed: onPressed,
        child: BodySmall(text),
      ),
    );
  }
}