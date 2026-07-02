import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/widgets/app_header.dart';
import '../cards/widgets/primary_pill_button.dart';
import 'account_application.dart';
import 'review_account_screen.dart';

class OpenAccountScreen extends StatefulWidget {
  const OpenAccountScreen({super.key});

  @override
  State<OpenAccountScreen> createState() => _OpenAccountScreenState();
}

class _OpenAccountScreenState extends State<OpenAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shortNameController = TextEditingController();
  String? _accountType;
  String? _currency;

  static const _accountTypes = ['Saving', 'Active', 'Family Account'];
  static const _currencies = ['SAR', 'USD', 'EUR', 'GBP'];

  @override
  void dispose() {
    _shortNameController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      AppPageRoute(
        builder: (_) => ReviewAccountScreen(
          application: AccountApplication(
            accountType: _accountType!,
            currency: _currency!,
            shortName: _shortNameController.text.trim(),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({String? hint}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.inputFill,
      hintText: hint,
      hintStyle: AppTextStyles.label,
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
      focusedErrorBorder: OutlineInputBorder(
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
            AppHeader(titleKey: 'open_new_account'),
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
                        Text(lang.t('account_type'), style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _accountType,
                          dropdownColor: AppColors.elevated,
                          style: AppTextStyles.value,
                          decoration:
                              _decoration(hint: lang.t('choose_account_type')),
                          items: _accountTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          validator: (value) =>
                              value == null ? lang.t('field_required') : null,
                          onChanged: (value) =>
                              setState(() => _accountType = value),
                        ),
                        const SizedBox(height: 18),
                        Text(lang.t('currency'), style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _currency,
                          dropdownColor: AppColors.elevated,
                          style: AppTextStyles.value,
                          decoration: _decoration(hint: lang.t('choose_currency')),
                          items: _currencies
                              .map((currency) => DropdownMenuItem(
                                    value: currency,
                                    child: Text(currency),
                                  ))
                              .toList(),
                          validator: (value) =>
                              value == null ? lang.t('field_required') : null,
                          onChanged: (value) => setState(() => _currency = value),
                        ),
                        const SizedBox(height: 18),
                        Text(lang.t('short_name'), style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _shortNameController,
                          textInputAction: TextInputAction.done,
                          style: AppTextStyles.value,
                          decoration: _decoration(hint: lang.t('short_name_hint')),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? lang.t('field_required')
                                  : null,
                          onFieldSubmitted: (_) => _continue(),
                        ),
                        const SizedBox(height: 32),
                        PrimaryPillButton(
                          label: lang.t('confirmation'),
                          onPressed: _continue,
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
