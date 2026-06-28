import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/transfer_provider.dart';

/// شريط تقدم خاص بمعالج التحويل — 4 خطوات قابلة للعرض
/// (نوع → مستفيد → تفاصيل → مراجعة) لا تشمل OTP والنجاح.
class TransferHeader extends StatelessWidget {
  final TransferStep step;
  final VoidCallback onClose;

  const TransferHeader({super.key, required this.step, required this.onClose});

  static const _orderedSteps = [
    TransferStep.selectType,
    TransferStep.selectBeneficiary,
    TransferStep.details,
    TransferStep.review,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _orderedSteps.indexOf(step);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
          ),
          if (currentIndex >= 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
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
                ),
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }
}
