import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/cards_provider.dart';

class IssueCardProgressBar extends StatelessWidget {
  final IssueCardStep currentStep;

  const IssueCardProgressBar({super.key, required this.currentStep});

  static const _orderedSteps = [
    IssueCardStep.selectType,
    IssueCardStep.details,
    IssueCardStep.review,
    IssueCardStep.otp,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _orderedSteps.indexOf(currentStep);

    return Row(
      children: List.generate(_orderedSteps.length, (index) {
        final isDone = index < currentIndex;
        final isActive = index == currentIndex;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == _orderedSteps.length - 1 ? 0 : 6,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.progressDone
                        : AppColors.progressPending,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
