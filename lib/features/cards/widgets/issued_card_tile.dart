import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/lang_provider.dart';
import '../models/card_type_option.dart';
import 'card_preview.dart';
import '../screens/card_detail_screen.dart';
import '../../../core/navigation/app_page_route.dart';

/// كرت بطاقة مُصدرة يُعرض بقائمة "بطاقاتي". الضغط عليها يفتح
/// CardDetailScreen، حيث يمكن التحكم بحالة التجميد وكل إعدادات
/// البطاقة الأخرى. لا يوجد تحكم مباشر بالتجميد من هذا الكرت نفسه.
class IssuedCardTile extends StatelessWidget {
  final IssuedCard card;

  const IssuedCardTile({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).push(
                AppPageRoute(
                  builder: (_) => CardDetailScreen(cardId: card.id),
                ),
              ),
              child: CardPreview(
                type: card.type,
                holderName: card.holderName,
                maskedNumber: card.maskedNumber,
                expiry: card.expiry,
              ),
            ),
          ),
          if (card.isFrozen)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.ac_unit, color: Colors.white, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      lang.t('card_frozen'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
