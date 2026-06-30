import 'package:flutter/material.dart';
import '../models/card_type_option.dart';

/// شعارات شبكات الدفع (VISA / mada) مرسومة يدويًا بنص مصمم بدقة
/// لمحاكاة الهوية البصرية الحقيقية لكل شبكة، بدل نص عادي.
class CardNetworkLogo extends StatelessWidget {
  final CardCategory category;
  final double height;

  const CardNetworkLogo({
    super.key,
    required this.category,
    this.height = 26,
  });

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case CardCategory.visaSignature:
      case CardCategory.visaPlatinum:
        return _VisaLogo(height: height);
      case CardCategory.mada:
        return _MadaLogo(height: height);
    }
  }
}

/// شعار VISA: نص مائل بخط عريض بنفس النسب التقريبية للشعار الحقيقي.
class _VisaLogo extends StatelessWidget {
  final double height;
  const _VisaLogo({required this.height});

  @override
  Widget build(BuildContext context) {
    return Text(
      'VISA',
      style: TextStyle(
        color: Colors.white,
        fontSize: height,
        fontWeight: FontWeight.w800,
        fontStyle: FontStyle.italic,
        letterSpacing: 1.2,
        height: 1,
        shadows: const [
          Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}

/// شعار mada: تصميم نصي بأحرف صغيرة متصلة بانحناء خفيف، بنفس روح
/// الهوية البصرية الرسمية (mada) — أحرف لاتينية صغيرة بخط عريض دائري.
class _MadaLogo extends StatelessWidget {
  final double height;
  const _MadaLogo({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: height * 0.35, vertical: height * 0.12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height * 0.5),
      ),
      child: Text(
        'mada',
        style: TextStyle(
          color: const Color(0xFF0F3D2E),
          fontSize: height * 0.78,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          height: 1,
        ),
      ),
    );
  }
}
