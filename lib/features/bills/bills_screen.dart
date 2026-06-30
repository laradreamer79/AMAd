import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/widgets/app_header.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          AppHeader(titleKey: 'bills'),
          Expanded(
            child: Center(
              child: Text(
                lang.t('bills_screen'),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
