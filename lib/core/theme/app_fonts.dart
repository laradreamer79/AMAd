import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام الخطوط لتطبيق Ameen — يجمع بين خط Display هندسي حديث
/// (Outfit) للعناوين والأرقام الكبيرة، خط Body واضح (Inter) للنصوص
/// العادية بالإنجليزي، وخط عربي حديث (IBM Plex Sans Arabic) لدعم RTL
/// بهوية بصرية متناسقة بدل الخط الافتراضي (Arial).
class AppFonts {
  AppFonts._();

  /// يُستخدم للعناوين الكبيرة، الأرقام البارزة (الرصيد)، وأسماء البطاقات
  static TextStyle display({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    bool isArabic = false,
  }) {
    if (isArabic) {
      return GoogleFonts.ibmPlexSansArabic(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
    }
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// يُستخدم للنصوص العادية، الأوصاف، والتسميات
  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
    bool isArabic = false,
  }) {
    if (isArabic) {
      return GoogleFonts.ibmPlexSansArabic(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// خط أرقام البطاقات وكل القيم المالية — يستخدم tabular figures
  /// لمحاذاة دقيقة (كل رقم بعرض ثابت، ضروري للأرقام المتغيّرة)
  static TextStyle numeric({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// يحدد الخط المناسب تلقائيًا (عربي أو إنجليزي) بناءً على اتجاه اللغة
  static String displayFamily(bool isRTL) =>
      isRTL ? GoogleFonts.ibmPlexSansArabic().fontFamily! : GoogleFonts.outfit().fontFamily!;

  static String bodyFamily(bool isRTL) =>
      isRTL ? GoogleFonts.ibmPlexSansArabic().fontFamily! : GoogleFonts.inter().fontFamily!;
}
