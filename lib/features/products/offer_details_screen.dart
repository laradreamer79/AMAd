import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/widgets/app_header.dart';
import '../cards/widgets/primary_pill_button.dart';
import 'offer_confirmation_screen.dart';
import 'products_screen.dart';

class OfferDetailsScreen extends StatelessWidget {
  final OfferItem offer;

  const OfferDetailsScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();

    return Directionality(
      textDirection: lang.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            AppHeader(titleKey: 'offer_details'),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.primary.withOpacity(0.18),
                              AppColors.card,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(offer.icon,
                                  color: AppColors.primary, size: 26),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              lang.isRTL ? offer.titleAr : offer.titleEn,
                              style: AppTextStyles.stepTitle.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              label: lang.t('partner'),
                              value: lang.isRTL ? offer.partnerAr : offer.partnerEn,
                            ),
                            _InfoRow(
                              label: lang.t('valid_until'),
                              value: offer.validUntil,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        lang.t('offer_terms_desc'),
                        style: AppTextStyles.label.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 32),
                      PrimaryPillButton(
                        label: lang.t('activate_offer'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            AppPageRoute(
                              builder: (_) =>
                                  OfferConfirmationScreen(offer: offer),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.value,
            ),
          ),
        ],
      ),
    );
  }
}
