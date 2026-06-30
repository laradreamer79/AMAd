import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/cards_provider.dart';
import 'issue_card_progress_bar.dart';

class IssueCardHeader extends StatelessWidget {
  final IssueCardStep step;
  final VoidCallback onClose;

  const IssueCardHeader({super.key, required this.step, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () {
              if (step == IssueCardStep.selectType) {
                onClose();
              } else {
                context.read<CardsProvider>().goBack();
              }
            },
            icon: Icon(
              isRtl ? Icons.arrow_forward : Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IssueCardProgressBar(currentStep: step),
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
