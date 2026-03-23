import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//
class AppTheme {
  static Color primaryColor =
  Color(0xC8B7F3EC);
  static Color titleColor = const Color.fromARGB(255, 0, 6, 4);
  static Color primaryAccent =Color(0xAD46CCBD);
  static Color secondaryColor =Color(0xAD58F3E1);

/*
 */

  /*
  static Color primaryAccent =
  const Color.fromRGBO(141, 122, 107, 1); // بني ترابي
  static Color secondaryColor =
  const Color.fromRGBO(238, 233, 230, 1); // أوف وايت
  static Color secondaryAccent = const Color.fromRGBO(255, 255, 255, 1); // أبيض
  static Color textColor = const Color.fromRGBO(141, 122, 107, 1); // بني ترابي
  static Color successColor = const Color.fromRGBO(57, 80, 70, 1); // أخضر غامق
  static Color highlightColor =
  const Color.fromRGBO(214, 201, 185, 1); // بيج فاتح
*/
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF3EDE8),
    textTheme: GoogleFonts.robotoTextTheme().copyWith(
      headlineLarge: GoogleFonts.changa(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headlineMedium: GoogleFonts.changa(
        fontSize:14,
        fontWeight: FontWeight.w600,
        color: AppTheme.titleColor,
      ),
      headlineSmall: GoogleFonts.changa(
        fontSize:12,
        color: Colors.grey,
      ),
      bodyLarge: GoogleFonts.changa(
        fontSize: 18,
        color: Colors.black,
      ),
      bodyMedium: GoogleFonts.changa(
        fontSize: 12,
        color: Colors.black,


      ),
      bodySmall: GoogleFonts.changa(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    ),
  );

}
