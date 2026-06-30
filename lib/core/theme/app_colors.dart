import 'package:flutter/material.dart';

/// نظام ألوان "Obsidian & Ember" — هوية بصرية متعددة الطبقات لتطبيق
/// Ameen المصرفي: كحلي عميق متدرّج (Obsidian) كقاعدة، برتقالي مشبّع
/// حيوي (Ember) كلون أساسي للتفاعل، ولمسة ذهبية (Gold) للعناصر
/// المميزة فقط — لا تُستخدم كلون عام بل لإبراز التميّز (بطاقات
/// Signature، أرصدة موجبة، إنجازات).
class AppColors {
  AppColors._();

  // ===== مستويات الخلفية (Obsidian) =====
  /// الخلفية الأساسية للتطبيق — أعمق من أي تصميم بنكي تقليدي
  static const Color background = Color(0xFF0A0E1A);

  /// مستوى ثاني: الكروت والعناصر المرتفعة بدرجة واحدة عن الخلفية
  static const Color card = Color(0xFF131826);

  /// مستوى ثالث: العناصر العائمة (modals، bottom sheets، popups)
  static const Color elevated = Color(0xFF1C2333);

  /// حدود خفيفة بين العناصر والخلفية
  static const Color cardBorder = Color(0xFF232B3D);

  /// تعبئة الحقول النصية (input fields)
  static const Color inputFill = Color(0xFF1A2030);

  // ===== الألوان الأساسية (Ember) =====
  /// البرتقالي الأساسي — أكثر تشبعًا وحيوية من أي تصميم سابق
  static const Color primary = Color(0xFFFF6B47);

  /// تدرّج ثاني لـ Ember (يُستخدم بالتدرجات والظلال، ليس كلون منفرد)
  static const Color primaryGlow = Color(0xFFFFA07A);

  static const Color primaryMuted = Color(0xFFF5C4B0);

  // ===== اللمسة الذهبية (Gold) — للتميّز فقط =====
  /// يُستخدم فقط: بطاقة Signature، أرصدة موجبة، شارات الإنجاز
  static const Color gold = Color(0xFFD4AF6A);
  static const Color goldMuted = Color(0xFFE8D9B8);

  // ===== النصوص =====
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B94A8);
  static const Color textMuted = Color(0xFF5A6378);

  // ===== الحالات =====
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF45B69);

  // ===== تدرّجات الخلفية الرئيسية =====
  /// تدرّج الخلفية الأساسي للشاشات — كحلي عميق بميل دقيق يعطي عمقًا
  static const List<Color> backgroundGradient = [
    Color(0xFF0A0E1A),
    Color(0xFF0D1220),
    Color(0xFF0A0E1A),
  ];

  /// تدرّج الكروت المرتفعة (لإعطاء عمق زجاجي خفيف)
  static const List<Color> cardGradient = [
    Color(0xFF161C2C),
    Color(0xFF131826),
  ];

  // ===== تدرّجات أنواع البطاقات =====
  static const List<Color> visaSignatureGradient = [
    Color(0xFF2B1E3D),
    Color(0xFF4A2F4F),
    Color(0xFF6B3F52),
  ];

  static const List<Color> visaPlatinumGradient = [
    Color(0xFF2C3E50),
    Color(0xFF3D4F61),
    Color(0xFF5A6B7A),
  ];

  static const List<Color> madaGradient = [
    Color(0xFF0F3D2E),
    Color(0xFF1A5C45),
    Color(0xFF2D7A5F),
  ];

  /// تدرّج ذهبي خاص بالبطاقات المميزة (Signature tier)
  static const List<Color> goldCardGradient = [
    Color(0xFF3D3220),
    Color(0xFF5C4A2E),
    Color(0xFFD4AF6A),
  ];

  // ===== شريط التقدم =====
  static const Color progressDone = Color(0xFF34D399);
  static const Color progressPending = Color(0xFF232B3D);

  // ===== نظام الظل (3 مستويات) =====
  /// مستوى 1: ظل خفيف للعناصر شبه المسطحة (كروت صغيرة، أزرار)
  static List<BoxShadow> shadowRaised1 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.18),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  /// مستوى 2: ظل متوسط للكروت الرئيسية (بطاقة بنكية، صناديق ملخص)
  static List<BoxShadow> shadowRaised2 = [
    BoxShadow(
      color: Colors.black.withOpacity(0.28),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primary.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  /// مستوى 3: ظل عميق للعناصر العائمة (bottom sheets، dialogs، nav)
  static List<BoxShadow> shadowFloating = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 28,
      offset: const Offset(0, -6),
    ),
  ];

  /// توهج خاص بالعناصر الذهبية المميزة
  static List<BoxShadow> shadowGoldGlow = [
    BoxShadow(
      color: gold.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
