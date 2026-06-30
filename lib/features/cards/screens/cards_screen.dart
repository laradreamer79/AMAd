import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/i18n/lang_provider.dart';
import '../../../core/widgets/app_header.dart';
import '../providers/cards_provider.dart';
import '../widgets/add_card_tile.dart';
import '../widgets/issued_card_tile.dart';
import 'issue_card_screen.dart';
import '../../../core/navigation/app_page_route.dart';

/// شاشة "بطاقاتي" — تُستخدم كأحد تبويبات التطبيق الرئيسية.
class CardsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const CardsScreen({super.key, this.onBack});

  void _openIssueCardWizard(BuildContext context) {
    Navigator.of(
      context,
    ).push(AppModalRoute(builder: (_) => const IssueCardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CardsProvider>();
    final lang = context.watch<LangProvider>();

    return Directionality(
      textDirection: lang.direction,
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            AppHeader(titleKey: 'my_cards', showBack: true, onBack: onBack),
            Expanded(
              child: SafeArea(
                top: false,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    ...provider.issuedCards.map(
                      (card) => IssuedCardTile(card: card),
                    ),
                    AddCardTile(onTap: () => _openIssueCardWizard(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
