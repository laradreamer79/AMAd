import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../models/beneficiary_model.dart';
import '../models/mock_beneficiaries.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_header.dart';

class SelectBeneficiaryStep extends StatelessWidget {
  final VoidCallback onClose;

  const SelectBeneficiaryStep({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransferProvider>();
    final lang = context.watch<LangProvider>();

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
                  Text(lang.t('select_beneficiary'), style: AppTextStyles.stepTitle),
                  const SizedBox(height: 8),
                  Text(lang.t('fast_beneficiaries'), style: AppTextStyles.stepSubtitle),
                  const SizedBox(height: 20),
                  ...mockBeneficiaries.map(
                    (b) => _BeneficiaryRow(
                      beneficiary: b,
                      isSelected: provider.selectedBeneficiary?.id == b.id,
                      onTap: () {
                        provider.selectBeneficiary(b);
                        provider.goTo(TransferStep.details);
                      },
                    ),
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

class _BeneficiaryRow extends StatelessWidget {
  final Beneficiary beneficiary;
  final bool isSelected;
  final VoidCallback onTap;

  const _BeneficiaryRow({
    required this.beneficiary,
    required this.isSelected,
    required this.onTap,
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
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.inputFill,
                child: Text(
                  beneficiary.name.characters.first,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(beneficiary.name, style: AppTextStyles.cardTypeName),
                    const SizedBox(height: 2),
                    Text(
                      '${beneficiary.bankName} • ${beneficiary.accountNumber}',
                      style: AppTextStyles.cardTypeDesc,
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
