import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/i18n/lang_provider.dart';
import '../cards/widgets/primary_pill_button.dart';
import 'product_application.dart';
import 'products_screen.dart';

class ProductConfirmationScreen extends StatelessWidget {
  final BankProduct product;
  final ProductApplication application;

  const ProductConfirmationScreen({
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
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        color: AppColors.success, size: 48),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    lang.t('application_submitted'),
                    style: AppTextStyles.stepTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${lang.isRTL ? product.titleAr : product.titleEn} • ${application.amount}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.value,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.t('application_submitted_desc'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryPillButton(
                      label: lang.t('done'),
                      onPressed: () =>
                          Navigator.popUntil(context, (r) => r.isFirst),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
