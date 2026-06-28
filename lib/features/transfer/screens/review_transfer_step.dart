import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../../account/providers/account_provider.dart';
import '../../cards/widgets/primary_pill_button.dart';
import '../models/beneficiary_model.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_header.dart';

class ReviewTransferStep extends StatelessWidget {
  final VoidCallback onClose;

  const ReviewTransferStep({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();
    final account = context.watch<AccountProvider>();
    final lang = context.watch<LangProvider>();
    final beneficiary = provider.selectedBeneficiary;

    return Directionality(
      textDirection: lang.direction,
      child: Column(
        children: [
          TransferHeader(step: provider.step, onClose: onClose),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.t('review_transfer_title'), style: AppTextStyles.stepTitle),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        _ReviewRow(
                          label: lang.t('transfer_type_label'),
                          value: provider.selectedType != null
                              ? lang.t(provider.selectedType!.labelKey)
                              : '—',
                        ),
                        const SizedBox(height: 14),
                        _ReviewRow(
                          label: lang.t('transfer_to'),
                          value: beneficiary?.name ?? '—',
                        ),
                        const SizedBox(height: 14),
                        _ReviewRow(
                          label: lang.t('account_label'),
                          value: beneficiary?.accountNumber ?? '—',
                        ),
                        const SizedBox(height: 14),
                        _ReviewRow(
                          label: lang.t('amount'),
                          value:
                              '${provider.amount.toStringAsFixed(2)} ${account.currency}',
                        ),
                        const SizedBox(height: 14),
                        _ReviewRow(
                          label: lang.t('reference'),
                          value: provider.transactionReference,
                        ),
                        if (provider.noteController.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _ReviewRow(
                            label: lang.t('note_label'),
                            value: provider.noteController.text.trim(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (provider.resultError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lang.t(provider.resultError!),
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  PrimaryPillButton(
                    label: lang.t('confirm'),
                    onPressed: account.canAfford(provider.amount)
                        ? () => provider.goTo(TransferStep.otp)
                        : null,
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

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.value,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}
