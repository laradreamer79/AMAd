import 'package:flutter/material.dart';

/// نقشة هندسية خفيفة (دوائر متراكبة شبه شفافة) تُرسم خلف محتوى البطاقة
/// لإعطائها عمقًا بصريًا، بنفس روح تصاميم البطاقات البنكية الحديثة
/// (مثل نمط الراجحي) دون أن تطغى على المحتوى الأساسي.
class CardPatternPainter extends CustomPainter {
  final Color color;

  CardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // دائرة كبيرة بأعلى يمين البطاقة (جزء منها خارج الحدود)
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.05),
      size.width * 0.32,
      paint,
    );

    // دائرة متوسطة متراكبة، أخف شفافية
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.15),
      size.width * 0.20,
      paint..color = color.withOpacity(0.05),
    );

    // خطوط قطرية رفيعة بأسفل يسار البطاقة (نقشة هندسية إضافية)
    final linePaint = Paint()
      ..color = color.withOpacity(0.06)
      ..strokeWidth = 1.2;

    for (int i = 0; i < 4; i++) {
      final offset = i * 14.0;
      canvas.drawLine(
        Offset(-10 + offset, size.height + 10),
        Offset(60 + offset, size.height - 60),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CardPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}
