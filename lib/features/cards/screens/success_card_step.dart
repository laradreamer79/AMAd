import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../providers/cards_provider.dart';
import '../widgets/card_preview.dart';
import '../widgets/primary_pill_button.dart';

class SuccessCardStep extends StatelessWidget {
  final VoidCallback onDone;

  const SuccessCardStep({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CardsProvider>();
    final lang = context.watch<LangProvider>();
    final card = provider.lastIssuedCard;

    return Directionality(
      textDirection: lang.direction,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 46,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                lang.t('card_issued_success'),
                style: AppTextStyles.stepTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                lang.t('card_issued_desc'),
                style: AppTextStyles.stepSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (card != null)
                CardPreview(
                  type: card.type,
                  holderName: card.holderName,
                  maskedNumber: card.maskedNumber,
                  expiry: card.expiry,
                ),
              const SizedBox(height: 40),
              PrimaryPillButton(
                label: lang.t('back_to_home'),
                onPressed: onDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
