import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../../account/providers/account_provider.dart';
import '../../cards/widgets/primary_pill_button.dart';
import '../providers/transfer_provider.dart';

class SuccessTransferStep extends StatelessWidget {
  final VoidCallback onDone;

  const SuccessTransferStep({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();
    final account = context.watch<AccountProvider>();
    final lang = context.watch<LangProvider>();

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
                child: const Icon(Icons.check, color: Colors.white, size: 46),
              ),
              const SizedBox(height: 24),
              Text(
                lang.t('transfer_success_title'),
                style: AppTextStyles.stepTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                lang.t('transfer_success_desc'),
                style: AppTextStyles.stepSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.amount.toStringAsFixed(2)} ${account.currency}',
                      style: AppTextStyles.value,
                    ),
                    Text(lang.t('amount'), style: AppTextStyles.label),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              PrimaryPillButton(
                label: lang.t('done'),
                onPressed: onDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
