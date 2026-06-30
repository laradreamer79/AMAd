import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../models/card_type_option.dart';
import '../providers/cards_provider.dart';
import '../widgets/card_preview.dart';
import '../widgets/issue_card_header.dart';
import '../widgets/primary_pill_button.dart';

class SelectCardTypeStep extends StatelessWidget {
  final VoidCallback onClose;

  const SelectCardTypeStep({super.key, required this.onClose});

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
                  Text(lang.t('issue_card_title'), style: AppTextStyles.stepTitle),
                  const SizedBox(height: 8),
                  Text(
                    lang.t('select_card_type_subtitle'),
                    style: AppTextStyles.stepSubtitle,
                  ),
                  const SizedBox(height: 24),
                  CardPreview(
                    type: provider.selectedType,
                    compact: true,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    lang.t('card_types'),
                    style: AppTextStyles.cardTypeName,
                  ),
                  const SizedBox(height: 12),
                  ...CardTypeOption.all.map(
                    (option) => _CardTypeRow(
                      option: option,
                      lang: lang,
                      isSelected:
                          option.category == provider.selectedType.category,
                      onTap: () => provider.selectType(option),
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryPillButton(
                    label: lang.t('next'),
                    onPressed: () => provider.goTo(IssueCardStep.details),
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

class _CardTypeRow extends StatelessWidget {
  final CardTypeOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final LangProvider lang;

  const _CardTypeRow({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: option.gradient,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.credit_card,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lang.t(option.nameKey), style: AppTextStyles.cardTypeName),
                    const SizedBox(height: 2),
                    Text(
                      option.annualFee == 0
                          ? lang.t('free')
                          : lang.t('annual_fee', {
                              'amount': option.annualFee.toStringAsFixed(0)
                            }),
                      style: AppTextStyles.cardTypeDesc,
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
