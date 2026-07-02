import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/i18n/lang_provider.dart';
import '../cards/widgets/primary_pill_button.dart';
import 'account_application.dart';

class AccountSuccessScreen extends StatelessWidget {
  final AccountApplication application;

  const AccountSuccessScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();

    return Directionality(
      textDirection: lang.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        color: AppColors.success, size: 48),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    lang.t('account_opened_success'),
                    style: AppTextStyles.stepTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${application.shortName} • ${application.currency}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryPillButton(
                      label: lang.t('done'),
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
