import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../providers/cards_provider.dart';
import '../widgets/issue_card_header.dart';
import '../widgets/primary_pill_button.dart';

class ReviewCardStep extends StatelessWidget {
  final VoidCallback onClose;

  const ReviewCardStep({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CardsProvider>();
    final lang = context.watch<LangProvider>();
    final type = provider.selectedType;

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
                  Text(lang.t('review_details_title'), style: AppTextStyles.stepTitle),
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
                        _ReviewRow(label: lang.t('card_type'), value: lang.t(type.nameKey)),
                        const SizedBox(height: 14),
                        _ReviewRow(
                          label: lang.t('card_holder_name'),
                          value: provider.holderNameController.text.trim(),
                        ),
                        const SizedBox(height: 14),
                        _ReviewRow(
                          label: lang.t('annual_fee_label'),
                          value: type.annualFee == 0
                              ? lang.t('free')
                              : '${type.annualFee.toStringAsFixed(0)} ${lang.isRTL ? "ر.س" : "SAR"}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            lang.t('review_info_text'),
                            style: AppTextStyles.label.copyWith(height: 1.5),
                            textAlign: lang.isRTL ? TextAlign.right : TextAlign.left,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: provider.toggleAgreement,
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            lang.t('confirm_data_text'),
                            style: AppTextStyles.value.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: lang.isRTL ? TextAlign.right : TextAlign.left,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _CheckboxBox(checked: provider.agreedToTerms),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  PrimaryPillButton(
                    label: lang.t('confirm'),
                    onPressed: provider.agreedToTerms
                        ? () => provider.goTo(IssueCardStep.otp)
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
            value.isEmpty ? '—' : value,
            style: AppTextStyles.value,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}

class _CheckboxBox extends StatelessWidget {
  final bool checked;

  const _CheckboxBox({required this.checked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: checked ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? AppColors.primary : AppColors.textSecondary,
          width: 2,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
