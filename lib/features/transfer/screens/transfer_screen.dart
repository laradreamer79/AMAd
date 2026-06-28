import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/i18n/lang_provider.dart';
import '../providers/transfer_provider.dart';
import 'transfer_type_step.dart';
import 'select_beneficiary_step.dart';
import 'transfer_details_step.dart';
import 'review_transfer_step.dart';
import 'otp_transfer_step.dart';
import 'success_transfer_step.dart';

/// نقطة الدخول لميزة "تحويل الأموال".
///
/// تستخدم TransferProvider الموجود في شجرة الـ widgets (المُوفَّر على
/// مستوى التطبيق في main.dart) — لا تنشئ نسخة جديدة منه.
class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TransferView();
  }
}

class _TransferView extends StatelessWidget {
  const _TransferView();

  void _handleClose(BuildContext context) {
    final provider = context.read<TransferProvider>();
    final lang = context.read<LangProvider>();
    if (provider.step == TransferStep.selectType) {
      provider.reset();
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
    final step = context.watch<TransferProvider>().step;

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

  Widget _buildStep(BuildContext context, TransferStep step) {
    switch (step) {
      case TransferStep.selectType:
        return TransferTypeStep(
          key: const ValueKey('selectType'),
          onClose: () => _handleClose(context),
        );
      case TransferStep.selectBeneficiary:
        return SelectBeneficiaryStep(
          key: const ValueKey('selectBeneficiary'),
          onClose: () => _handleClose(context),
        );
      case TransferStep.details:
        return TransferDetailsStep(
          key: const ValueKey('details'),
          onClose: () => _handleClose(context),
        );
      case TransferStep.review:
        return ReviewTransferStep(
          key: const ValueKey('review'),
          onClose: () => _handleClose(context),
        );
      case TransferStep.otp:
        return OtpTransferStep(
          key: const ValueKey('otp'),
          onClose: () => _handleClose(context),
        );
      case TransferStep.success:
        return SuccessTransferStep(
          key: const ValueKey('success'),
          onDone: () {
            context.read<TransferProvider>().reset();
            Navigator.of(context).pop();
          },
        );
    }
  }
}
