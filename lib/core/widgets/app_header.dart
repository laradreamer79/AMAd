import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../i18n/lang_provider.dart';

/// هيدر مخصص يُستخدم في أعلى كل شاشة رئيسية بدل AppBar الافتراضي.
/// يحتوي عنوان الشاشة + زر دائري عائم لتبديل اللغة (AR/EN)، مع حدّ
/// سفلي خفيف يفصله بصريًا عن محتوى الشاشة.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String titleKey;

  const AppHeader({super.key, required this.titleKey});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.6),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                lang.t(titleKey),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            _LanguageToggleButton(lang: lang),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggleButton extends StatefulWidget {
  final LangProvider lang;

  const _LanguageToggleButton({required this.lang});

  @override
  State<_LanguageToggleButton> createState() => _LanguageToggleButtonState();
}

class _LanguageToggleButtonState extends State<_LanguageToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.reverse();
    widget.lang.toggle();
    await _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final nextLabel = widget.lang.isRTL ? 'EN' : 'AR';

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            nextLabel,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
