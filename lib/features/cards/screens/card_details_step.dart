import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../providers/cards_provider.dart';
import '../widgets/card_preview.dart';
import '../widgets/issue_card_header.dart';
import '../widgets/primary_pill_button.dart';

class CardDetailsStep extends StatelessWidget {
  final VoidCallback onClose;

  const CardDetailsStep({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CardsProvider>();
    final lang = context.watch<LangProvider>();

    return Directionality(
      textDirection: lang.direction,
      child: Column(
        children: [
          IssueCardHeader(step: provider.step, onClose: onClose),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.t('card_details_title'), style: AppTextStyles.stepTitle),
                  const SizedBox(height: 8),
                  Text(
                    lang.t('enter_card_details'),
                    style: AppTextStyles.stepSubtitle,
                  ),
                  const SizedBox(height: 24),
                  CardPreview(
                    type: provider.selectedType,
                    holderName: provider.holderNameController.text.isEmpty
                        ? null
                        : provider.holderNameController.text,
                    compact: true,
                  ),
                  const SizedBox(height: 28),
                  Text(lang.t('card_holder_name'), style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: provider.holderNameController,
                      textAlign: lang.isRTL ? TextAlign.right : TextAlign.left,
                      style: AppTextStyles.value,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: lang.t('card_holder_hint'),
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
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
                        _SummaryRow(
                          label: lang.t('card_type'),
                          value: lang.t(provider.selectedType.nameKey),
                        ),
                        const SizedBox(height: 12),
                        _SummaryRow(
                          label: lang.t('annual_fee_label'),
                          value: provider.selectedType.annualFee == 0
                              ? lang.t('free')
                              : '${provider.selectedType.annualFee.toStringAsFixed(0)} ${lang.isRTL ? "ر.س" : "SAR"}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  PrimaryPillButton(
                    label: lang.t('next'),
                    onPressed: provider.canProceedFromDetails
                        ? () => provider.goTo(IssueCardStep.review)
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value, style: AppTextStyles.value),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}
