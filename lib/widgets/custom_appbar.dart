import 'package:badilni_v1/theme/app_theme.dart';
import 'package:flutter/material.dart';

import '../style/styled_text.dart';
//
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final IconData? icon;
  final VoidCallback? onIconPressed;
  final bool centerTitle; // المعامل الاختياري لتوسيط العنوان


  const CustomAppBar({
    Key? key,
    this.title,
    this.icon,
    this.onIconPressed,
    this.centerTitle = false, // قيمة افتراضية

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // إذا لم يتم تمرير عنوان، يمكن ترك الـ title فارغاً أو استخدام قيمة افتراضية
      title: title != null ? StyledText(title!) : null,
      backgroundColor: AppTheme.primaryAccent,
      centerTitle: centerTitle, // استخدام المعامل هنا

      // إذا تم تمرير أيقونة، يتم عرضها مع زر الضغط
      actions: icon != null
          ? [
              IconButton(
                icon: Icon(icon),
                onPressed: onIconPressed,
              )
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
