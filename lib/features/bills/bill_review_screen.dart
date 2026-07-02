import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/widgets/app_header.dart';
import '../cards/widgets/primary_pill_button.dart';
import 'bill_otp_screen.dart';
import 'bill_payment.dart';

class BillReviewScreen extends StatelessWidget {
  final BillPayment payment;

  const BillReviewScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();

    return Directionality(
      textDirection: lang.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            AppHeader(titleKey: 'review'),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.t('bill_info'), style: AppTextStyles.stepTitle),
                      const SizedBox(height: 16),
                      _ReviewRow(label: lang.t('biller'), value: payment.bill.biller),
                      _ReviewRow(label: lang.t('bills'), value: payment.bill.name),
                      _ReviewRow(
                        label: lang.t('bill_number'),
                        value: payment.bill.accountNumber,
                      ),
                      _ReviewRow(label: lang.t('pay_from'), value: payment.account),
                      _ReviewRow(label: lang.t('bill_amount'), value: payment.amount),
                      _ReviewRow(
                        label: lang.t('due_date'),
                        value: payment.bill.dueDate,
                      ),
                      const SizedBox(height: 28),
                      PrimaryPillButton(
                        label: lang.t('confirm'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            AppPageRoute(
                              builder: (_) => BillOtpScreen(payment: payment),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.value,
            ),
          ),
        ],
      ),
    );
  }
}
