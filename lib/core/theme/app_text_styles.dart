import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

/// نظام Typography لتطبيق Ameen — يستخدم AppFonts (Outfit/Inter/IBM
/// Plex Sans Arabic) بدل الخط الافتراضي. كل الأنماط أصبحت getters
/// (لا const) لأن خطوط Google Fonts تُحمَّل وقت التشغيل.
///
/// ملاحظة: هذي الأنماط افتراضيًا بالخط الإنجليزي (isArabic: false).
/// الشاشات اللي تحتاج الخط العربي ديناميكيًا (حسب LangProvider) تستخدم
/// .copyWith(fontFamily: ...) أو AppFonts مباشرة — راجعي الاستخدام
/// الفعلي بكل شاشة عند الحاجة لدعم RTL الكامل بالخط.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle stepTitle = AppFonts.display(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle stepSubtitle = AppFonts.body(
    fontSize: 14,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static TextStyle label = AppFonts.body(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static TextStyle value = AppFonts.body(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle buttonText = AppFonts.display(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle cardTypeName = AppFonts.display(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle cardTypeDesc = AppFonts.body(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  /// نمط خاص بالأرقام المالية الكبيرة (الرصيد بصفحة Home)
  static TextStyle balanceDisplay = AppFonts.numeric(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// نمط خاص بعناوين الأقسام (Quick Actions، Recent Transactions...)
  static TextStyle sectionTitle = AppFonts.display(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );
}
