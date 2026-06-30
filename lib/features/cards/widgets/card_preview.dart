import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/card_type_option.dart';
import 'card_chip.dart';
import 'card_network_logo.dart';
import 'card_pattern_painter.dart';

/// معاينة بطاقة بنكية واقعية واحترافية: شريحة EMV معدنية، نقشة هندسية
/// خلفية، شعار شبكة دفع حقيقي الشكل، وتأثير glassmorphism خفيف
/// (لمعان زجاجي قطري) بستايل قريب من تصاميم البنوك السعودية الحديثة.
class CardPreview extends StatelessWidget {
  final CardTypeOption type;
  final String? holderName;
  final String? maskedNumber;
  final String? expiry;
  final bool compact;

  const CardPreview({
    super.key,
    required this.type,
    this.holderName,
    this.maskedNumber,
    this.expiry,
    this.compact = false,
  });

  bool get _isGoldChip => type.category != CardCategory.mada;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      height: compact ? 175 : 215,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // الخلفية المتدرجة الأساسية
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: type.gradient,
                ),
              ),
            ),

            // النقشة الهندسية الخلفية
            Positioned.fill(
              child: CustomPaint(
                painter: CardPatternPainter(color: Colors.white),
              ),
            ),

            // تأثير glassmorphism: لمعان قطري شفاف فوق الزاوية العلوية
            Positioned(
              top: -40,
              left: -30,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.18),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            // طبقة زجاجية إضافية خفيفة (يعطي عمق ونعومة بصرية)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(color: Colors.white.withOpacity(0.01)),
              ),
            ),

            // حد خفيف على إطار البطاقة (لمعان حافة زجاجية)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                ),
              ),
            ),

            // المحتوى الأساسي
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CardChip(golden: _isGoldChip),
                      CardNetworkLogo(category: type.category, height: 24),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    maskedNumber ?? '•••• •••• •••• ••••',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      letterSpacing: 2.4,
                      fontWeight: FontWeight.w500,
                      fontFeatures: [FontFeature.tabularFigures()],
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARD HOLDER',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              holderName?.toUpperCase() ?? 'CARD HOLDER NAME',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'VALID THRU',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            expiry ?? '••/••',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
