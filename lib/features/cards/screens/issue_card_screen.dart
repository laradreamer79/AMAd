import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/cards_provider.dart';
import '../../../core/i18n/lang_provider.dart';
import 'card_details_step.dart';
import 'otp_card_step.dart';
import 'review_card_step.dart';
import 'select_card_type_step.dart';
import 'success_card_step.dart';

/// نقطة الدخول لميزة "إصدار بطاقة جديدة".
///
/// هذي الشاشة تستخدم CardsProvider الموجود في شجرة الـ widgets
/// (المُوفَّر مرة واحدة على مستوى التطبيق في main.dart) — ولا تنشئ نسخة
/// جديدة منه. هذا ضروري لأن البطاقة الجديدة يجب أن تظهر في شاشة
/// "البطاقات" بعد إغلاق المعالج.
class IssueCardScreen extends StatelessWidget {
  const IssueCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _IssueCardView();
  }
}

class _IssueCardView extends StatelessWidget {
  const _IssueCardView();

  void _handleClose(BuildContext context) {
    final provider = context.read<CardsProvider>();
    final lang = context.read<LangProvider>();
    if (provider.step == IssueCardStep.selectType) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: lang.direction,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            lang.t('cancel_issuance_title'),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            lang.t('cancel_issuance_desc'),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                lang.t('continue_label'),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.reset();
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                lang.t('close'),
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = context.watch<CardsProvider>().step;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildStep(context, step),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, IssueCardStep step) {
    switch (step) {
      case IssueCardStep.selectType:
        return SelectCardTypeStep(
          key: const ValueKey('selectType'),
          onClose: () => _handleClose(context),
        );
      case IssueCardStep.details:
        return CardDetailsStep(
          key: const ValueKey('details'),
          onClose: () => _handleClose(context),
        );
      case IssueCardStep.review:
        return ReviewCardStep(
          key: const ValueKey('review'),
          onClose: () => _handleClose(context),
        );
      case IssueCardStep.otp:
        return OtpCardStep(
          key: const ValueKey('otp'),
          onClose: () => _handleClose(context),
        );
      case IssueCardStep.success:
        return SuccessCardStep(
          key: const ValueKey('success'),
          onDone: () {
            context.read<CardsProvider>().reset();
            Navigator.of(context).pop();
          },
        );
    }
  }
}
