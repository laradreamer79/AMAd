import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../../account/providers/account_provider.dart';
import '../../cards/widgets/primary_pill_button.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_header.dart';

class TransferDetailsStep extends StatelessWidget {
  final VoidCallback onClose;

  const TransferDetailsStep({super.key, required this.onClose});

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
                  Text(lang.t('transfer_details_title'), style: AppTextStyles.stepTitle),
                  const SizedBox(height: 8),
                  Text(lang.t('select_source_account'), style: AppTextStyles.stepSubtitle),
                  const SizedBox(height: 24),

                  if (beneficiary != null) ...[
                    Text(lang.t('beneficiary'), style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(beneficiary.name, style: AppTextStyles.cardTypeName),
                          const SizedBox(height: 4),
                          Text(
                            '${beneficiary.bankName} • ${beneficiary.accountNumber}',
                            style: AppTextStyles.cardTypeDesc,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Text(lang.t('transfer_from'), style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(account.accountNumber, style: AppTextStyles.value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(lang.t('amount'), style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: provider.amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: lang.isRTL ? TextAlign.right : TextAlign.left,
                      style: AppTextStyles.value,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        hintText: lang.t('enter_amount'),
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        suffixText: account.currency,
                        suffixStyle: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  if (provider.amount > 0 && !account.canAfford(provider.amount))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        lang.t('insufficient_balance'),
                        style: const TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 20),

                  Text(lang.t('transfer_reason'), style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TransferReason.values.map((reason) {
                      final isSelected = provider.selectedReason == reason;
                      return GestureDetector(
                        onTap: () => provider.selectReason(reason),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            lang.t(reason.labelKey),
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  Text(lang.t('note_optional'), style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: provider.noteController,
                      textAlign: lang.isRTL ? TextAlign.right : TextAlign.left,
                      style: AppTextStyles.value,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: lang.t('add_note'),
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  PrimaryPillButton(
                    label: lang.t('next'),
                    onPressed: (provider.canProceedFromDetails &&
                            account.canAfford(provider.amount))
                        ? () => provider.goTo(TransferStep.review)
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
