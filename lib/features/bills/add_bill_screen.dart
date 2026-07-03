import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/widgets/app_header.dart';
import '../cards/widgets/primary_pill_button.dart';
import 'bill.dart';
import 'providers/bills_provider.dart';

/// شاشة إضافة فاتورة جديدة فعليًا — تُضيف الفاتورة لـ BillsProvider
/// وتظهر مباشرة بقائمة الفواتير المحفوظة.
class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _billerController = TextEditingController();
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
  final _dueDateController = TextEditingController();
  BillCategory? _category;
  bool _isSaving = false;

  @override
  void dispose() {
    _billerController.dispose();
    _numberController.dispose();
    _amountController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _submit(LangProvider lang) async {
    if (!_formKey.currentState!.validate() || _category == null) {
      if (_category == null) setState(() {});
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final bill = Bill(
      name: _billerController.text.trim(),
      biller: _billerController.text.trim(),
      accountNumber: _numberController.text.trim(),
      amount: '${_amountController.text.trim()} SAR',
      dueDate: _dueDateController.text.trim().isEmpty
          ? '—'
          : _dueDateController.text.trim(),
      category: _category!,
    );

    if (!mounted) return;
    context.read<BillsProvider>().addBill(bill);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang.t('bill_added_success')),
        backgroundColor: AppColors.success,
      ),
    );
  }

  InputDecoration _decoration(String label, LangProvider lang) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.label,
      filled: true,
      fillColor: AppColors.inputFill,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();

    return Directionality(
      textDirection: lang.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            AppHeader(titleKey: 'add_bill_title'),
            Expanded(
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang.t('bill_category'), style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.inputFill,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: DropdownButtonFormField<BillCategory>(
                            initialValue: _category,
                            dropdownColor: AppColors.elevated,
                            style: AppTextStyles.value,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            hint: Text(
                              lang.t('select_category'),
                              style: AppTextStyles.label,
                            ),
                            items: BillCategory.values
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(c.icon,
                                            size: 18, color: AppColors.primary),
                                        const SizedBox(width: 10),
                                        Text(c.title),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _category = v),
                            validator: (v) =>
                                v == null ? lang.t('field_required') : null,
                          ),
                        ),
                        const SizedBox(height: 18),

                        Text(lang.t('biller_name'), style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _billerController,
                          style: AppTextStyles.value,
                          decoration: _decoration(lang.t('biller_name'), lang),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? lang.t('field_required')
                              : null,
                        ),
                        const SizedBox(height: 18),

                        Text(lang.t('bill_number'), style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _numberController,
                          style: AppTextStyles.value,
                          decoration: _decoration(lang.t('bill_number'), lang),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? lang.t('field_required')
                              : null,
                        ),
                        const SizedBox(height: 18),

                        Text(lang.t('bill_amount'), style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: AppTextStyles.value,
                          decoration: _decoration(lang.t('bill_amount'), lang)
                              .copyWith(
                            suffixText: 'SAR',
                            suffixStyle: AppTextStyles.label,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return lang.t('field_required');
                            }
                            if (double.tryParse(v.trim()) == null) {
                              return lang.t('enter_valid_amount');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        Text(lang.t('due_date'), style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _dueDateController,
                          style: AppTextStyles.value,
                          decoration:
                              _decoration('e.g. 30 Jul 2026', lang),
                        ),

                        const SizedBox(height: 32),
                        PrimaryPillButton(
                          label: lang.t('add_bill'),
                          isLoading: _isSaving,
                          onPressed: () => _submit(lang),
                        ),
                      ],
                    ),
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
