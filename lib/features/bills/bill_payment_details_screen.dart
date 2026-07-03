import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/widgets/app_header.dart';
import '../cards/widgets/primary_pill_button.dart';
import 'bill.dart';
import 'bill_payment.dart';
import 'bill_review_screen.dart';

class BillPaymentDetailsScreen extends StatefulWidget {
  final Bill bill;

  const BillPaymentDetailsScreen({super.key, required this.bill});

  @override
  State<BillPaymentDetailsScreen> createState() =>
      _BillPaymentDetailsScreenState();
}

class _BillPaymentDetailsScreenState extends State<BillPaymentDetailsScreen> {
  final _amountController = TextEditingController();
  String? _selectedAccount;
  bool _touchedAccount = false;

  static const _accounts = ['SA **** **** **** 9012', 'SA **** **** **** 3344'];

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.bill.amount.replaceAll(' SAR', '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _review() {
    final amount = _amountController.text.trim();
    setState(() => _touchedAccount = true);
    if (_selectedAccount == null ||
        amount.isEmpty ||
        double.tryParse(amount) == null) {
      return;
    }

    Navigator.push(
      context,
      AppPageRoute(
        builder: (_) => BillReviewScreen(
          payment: BillPayment(
            bill: widget.bill,
            account: _selectedAccount!,
            amount: '$amount SAR',
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({String? suffix, String? hint}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.inputFill,
      hintText: hint,
      hintStyle: AppTextStyles.label,
      suffixText: suffix,
      suffixStyle: AppTextStyles.label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final bill = widget.bill;
    final amount = _amountController.text.trim();
    final amountValid = amount.isNotEmpty && double.tryParse(amount) != null;

    return Directionality(
      textDirection: lang.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            AppHeader(titleKey: 'payment_details'),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.cardGradient,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: AppColors.shadowRaised1,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(bill.category.icon,
                                      color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(bill.name,
                                      style: AppTextStyles.stepTitle
                                          .copyWith(fontSize: 18)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(label: lang.t('biller'), value: bill.biller),
                            _InfoRow(
                                label: lang.t('bill_number'),
                                value: bill.accountNumber),
                            _InfoRow(
                                label: lang.t('due_date'), value: bill.dueDate),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(lang.t('pay_from'), style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAccount,
                        dropdownColor: AppColors.elevated,
                        style: AppTextStyles.value,
                        decoration: _decoration(hint: lang.t('choose_account')),
                        items: _accounts
                            .map((account) => DropdownMenuItem(
                                  value: account,
                                  child: Text(account),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedAccount = value),
                      ),
                      if (_touchedAccount && _selectedAccount == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(lang.t('field_required'),
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.error)),
                        ),
                      const SizedBox(height: 18),
                      Text(lang.t('bill_amount'), style: AppTextStyles.label),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: AppTextStyles.value,
                        decoration: _decoration(suffix: 'SAR'),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_touchedAccount && !amountValid)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(lang.t('enter_valid_amount'),
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.error)),
                        ),
                      const SizedBox(height: 32),
                      PrimaryPillButton(
                        label: lang.t('review'),
                        onPressed: _review,
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
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
