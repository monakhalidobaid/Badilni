import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../theme/app_theme.dart';
//
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white, // خلفية شريط التنقل
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), // زوايا ناعمة
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // لون الظل
              blurRadius: 15, // درجة النعومة
              offset: const Offset(0, -2), // تحريك الظل للأعلى قليلاً
            ),
          ],
        ),
        child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Symbols.person, weight: 1000),
                  label: 'الملف الشخصي',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Symbols.home, weight: 1000),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Symbols.menu_book, weight: 1000),
                  label: 'مكتبتي الإلكترونية',
                ),
              ],
              currentIndex: currentIndex,
              selectedItemColor: AppTheme.primaryAccent,
              onTap: onTap, // عند النقر على أي زر سيتم تغيير الصفحة
            )));
  }
}
