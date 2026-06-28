import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';
import '../providers/auth_provider.dart';

/// شاشة قفل التطبيق — تظهر عند الإقلاع وتطلب رمز PIN مكوّن من 4 أرقام.
/// لا تستخدم Navigator (تُعرض مباشرة فوق التطبيق من خلال main.dart)
/// لأنها ليست "شاشة" بالمعنى التقليدي بل حارس وصول (gate) للتطبيق كله.
class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LangProvider>();

    return Directionality(
      textDirection: lang.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

              // أيقونة القفل
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              Text(lang.t('welcome_back'), style: AppTextStyles.stepTitle),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  lang.t('enter_pin_desc'),
                  style: AppTextStyles.stepSubtitle,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 36),

              // مؤشرات الـ PIN (4 دوائر)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(AuthProvider.pinLength, (i) {
                  final isFilled = auth.enteredDigits[i].isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled ? AppColors.primary : Colors.transparent,
                        border: Border.all(
                          color: isFilled ? AppColors.primary : AppColors.cardBorder,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              if (auth.pinError != null) ...[
                const SizedBox(height: 16),
                Text(
                  lang.t(auth.pinError!),
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ] else if (auth.isVerifying) ...[
                const SizedBox(height: 16),
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ],

              const Spacer(),

                        // لوحة الأرقام
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: _Numpad(auth: auth, lang: lang),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: () => _showForgotPinDialog(context, lang),
                          child: Text(
                            lang.t('forgot_pin'),
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showForgotPinDialog(BuildContext context, LangProvider lang) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: lang.direction,
        child: AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            lang.t('forgot_pin'),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            lang.t('forgot_pin_message'),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                lang.t('ok'),
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  final AuthProvider auth;
  final LangProvider lang;

  const _Numpad({required this.auth, required this.lang});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((digit) => _NumKey(
                label: digit,
                onTap: () => auth.appendDigit(digit),
              )).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 70, height: 70),
            _NumKey(label: '0', onTap: () => auth.appendDigit('0')),
            _NumKey(
              icon: Icons.backspace_outlined,
              onTap: auth.removeLastDigit,
            ),
          ],
        ),
      ],
    );
  }
}

class _NumKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _NumKey({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(35),
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: label != null
            ? Text(
                label!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              )
            : Icon(icon, color: AppColors.textSecondary, size: 24),
      ),
    );
  }
}
