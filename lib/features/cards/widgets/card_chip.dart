import 'package:flutter/material.dart';

/// شريحة بطاقة معدنية واقعية (EMV chip) — تُحاكي الشريحة الذهبية/الفضية
/// الحقيقية بخطوطها الأفقية الدقيقة وتدرّجها المعدني، بدل مستطيل لون واحد.
class CardChip extends StatelessWidget {
  final double width;
  final double height;
  final bool golden;

  const CardChip({
    super.key,
    this.width = 42,
    this.height = 32,
    this.golden = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = golden
        ? const [
            Color(0xFFE8D48A),
            Color(0xFFC9A84C),
            Color(0xFFB8923A),
            Color(0xFFE8D48A),
          ]
        : const [
            Color(0xFFE8EAED),
            Color(0xFFBFC4CC),
            Color(0xFFA0A6B0),
            Color(0xFFE8EAED),
          ];

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ChipLinesPainter(lineColor: colors[2].withOpacity(0.55)),
      ),
    );
  }
}

class _ChipLinesPainter extends CustomPainter {
  final Color lineColor;
  _ChipLinesPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    // خطوط أفقية تقسّم الشريحة لثلاثة أجزاء (تصميم EMV نموذجي)
    final rowY1 = size.height * 0.35;
    final rowY2 = size.height * 0.65;
    canvas.drawLine(Offset(2, rowY1), Offset(size.width - 2, rowY1), paint);
    canvas.drawLine(Offset(2, rowY2), Offset(size.width - 2, rowY2), paint);

    // خطوط عمودية قصيرة بالمنتصف (محاكاة دوائر التلامس)
    final midY = size.height / 2;
    for (final dx in [size.width * 0.3, size.width * 0.5, size.width * 0.7]) {
      canvas.drawLine(
        Offset(dx, rowY1),
        Offset(dx, rowY2),
        paint,
      );
    }

    // مربع صغير بالمنتصف (نقطة التلامس الرئيسية)
    final centerRect = Rect.fromCenter(
      center: Offset(size.width / 2, midY),
      width: size.width * 0.22,
      height: size.height * 0.3,
    );
    canvas.drawRect(centerRect, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
