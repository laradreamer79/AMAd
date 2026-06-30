import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../models/beneficiary_model.dart';
import '../providers/transfer_provider.dart';
import '../widgets/transfer_header.dart';

class TransferTypeStep extends StatelessWidget {
  final VoidCallback onClose;

  const TransferTypeStep({super.key, required this.onClose});

  static const _icons = {
    TransferType.local: Icons.public,
    TransferType.international: Icons.flight_takeoff,
    TransferType.sameBank: Icons.account_balance,
    TransferType.betweenAccounts: Icons.swap_horiz,
  };

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
                  Text(lang.t('transfer_title'), style: AppTextStyles.stepTitle),
                  const SizedBox(height: 8),
                  Text(
                    lang.t('transfer_select_type'),
                    style: AppTextStyles.stepSubtitle,
                  ),
                  const SizedBox(height: 24),
                  ...TransferType.values.map(
                    (type) => _TypeRow(
                      type: type,
                      icon: _icons[type]!,
                      isSelected: provider.selectedType == type,
                      lang: lang,
                      onTap: () {
                        provider.selectType(type);
                        provider.goTo(TransferStep.selectBeneficiary);
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

class _TypeRow extends StatelessWidget {
  final TransferType type;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final LangProvider lang;

  const _TypeRow({
    required this.type,
    required this.icon,
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
          padding: const EdgeInsets.all(16),
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
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  lang.t(type.labelKey),
                  style: AppTextStyles.cardTypeName,
                ),
              ),
              Icon(
                lang.isRTL ? Icons.chevron_left : Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
