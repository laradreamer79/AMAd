import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/i18n/lang_provider.dart';

/// كرت "بطاقة جديدة +" المستخدم في شاشة البطاقات الرئيسية لفتح معالج الإصدار.
class AddCardTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddCardTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();

    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.cardBorder,
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(lang.t('new_card'), style: AppTextStyles.cardTypeName),
          ],
        ),
        ),
      ),
    );
  }
}
