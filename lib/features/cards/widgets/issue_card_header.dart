import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/cards_provider.dart';
import 'issue_card_progress_bar.dart';

class IssueCardHeader extends StatelessWidget {
  final IssueCardStep step;
  final VoidCallback onClose;

  const IssueCardHeader({
    super.key,
    required this.step,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IssueCardProgressBar(currentStep: step),
            ),
          ),
          const Icon(Icons.chevron_left, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
