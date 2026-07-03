import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/widgets/app_header.dart';
import '../cards/widgets/primary_pill_button.dart';
import 'product_application.dart';
import 'product_confirmation_screen.dart';
import 'products_screen.dart';

class ProductReviewScreen extends StatelessWidget {
  final BankProduct product;
  final ProductApplication application;

  const ProductReviewScreen({
    super.key,
    required this.product,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();

    return Directionality(
      textDirection: lang.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            AppHeader(titleKey: 'review'),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.t('application_review'),
                          style: AppTextStyles.stepTitle),
                      const SizedBox(height: 16),
                      _ReviewRow(
                        label: lang.t('product_type'),
                        value: lang.isRTL ? product.titleAr : product.titleEn,
                      ),
                      _ReviewRow(
                        label: lang.t('requested_amount'),
                        value: application.amount,
                      ),
                      _ReviewRow(
                        label: lang.t('duration'),
                        value: application.duration,
                      ),
                      const SizedBox(height: 28),
                      PrimaryPillButton(
                        label: lang.t('confirm_submit'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            AppPageRoute(
                              builder: (_) => ProductConfirmationScreen(
                                product: product,
                                application: application,
                              ),
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

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
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
