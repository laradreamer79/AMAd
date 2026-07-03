import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/widgets/app_header.dart';
import '../cards/widgets/primary_pill_button.dart';
import 'product_application.dart';
import 'product_review_screen.dart';
import 'products_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final BankProduct product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _duration;
  bool _agreed = false;
  bool _touchedAgree = false;

  static const _durations = ['12', '24', '36', '60'];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _continue(LangProvider lang) {
    setState(() => _touchedAgree = true);
    if (!_formKey.currentState!.validate() || !_agreed) return;

    Navigator.push(
      context,
      AppPageRoute(
        builder: (_) => ProductReviewScreen(
          product: widget.product,
          application: ProductApplication(
            amount: '${_amountController.text.trim()} SAR',
            duration:
                '${_duration!} ${lang.isRTL ? 'شهر' : 'months'}',
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final product = widget.product;

    return Directionality(
      textDirection: lang.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            AppHeader(titleKey: 'product_type'),
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: product.gradient,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: AppColors.shadowRaised1,
                          ),
                          child: Row(
                            children: [
                              Icon(product.icon, color: Colors.white, size: 30),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.isRTL
                                          ? product.titleAr
                                          : product.titleEn,
                                      style: AppTextStyles.stepTitle
                                          .copyWith(fontSize: 17, color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      lang.isRTL ? product.descAr : product.descEn,
                                      style: AppTextStyles.label
                                          .copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(lang.t('requested_amount'), style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: AppTextStyles.value,
                          decoration: _decoration(
                            suffix: 'SAR',
                            hint: lang.t('requested_amount_hint'),
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
                        Text(lang.t('duration'), style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _duration,
                          dropdownColor: AppColors.elevated,
                          style: AppTextStyles.value,
                          decoration:
                              _decoration(hint: lang.t('choose_duration')),
                          items: _durations
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    '$d ${lang.isRTL ? 'شهر' : 'months'}',
                                  ),
                                ),
                              )
                              .toList(),
                          validator: (v) =>
                              v == null ? lang.t('field_required') : null,
                          onChanged: (v) => setState(() => _duration = v),
                        ),
                        const SizedBox(height: 20),
                        InkWell(
                          onTap: () => setState(() => _agreed = !_agreed),
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _agreed,
                                activeColor: AppColors.primary,
                                onChanged: (v) =>
                                    setState(() => _agreed = v ?? false),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    lang.t('agree_terms'),
                                    style: AppTextStyles.label,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_touchedAgree && !_agreed)
                          Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Text(
                              lang.t('field_required'),
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.error),
                            ),
                          ),
                        const SizedBox(height: 28),
                        PrimaryPillButton(
                          label: lang.t('submit_application'),
                          onPressed: () => _continue(lang),
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
