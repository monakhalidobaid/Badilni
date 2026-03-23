import 'package:badilni_v1/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../style/styled_text.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(280, 25), // حجم الزر
        backgroundColor: AppTheme.primaryColor,
        textStyle: const TextStyle(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Expanded( // يجعل النص في المنتصف
            child: Center(
              child: BodySmall(text),
            ),
          ),

        ],
      ),
    );
  }
}
