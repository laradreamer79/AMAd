import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_fonts.dart';
import '../../core/i18n/lang_provider.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/widgets/app_header.dart';
import '../account/providers/account_provider.dart';
import '../account/models/transaction_model.dart';
import '../accounts/accounts_screen.dart';
import '../transfer/screens/transfer_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onSelectTab;

  const HomeScreen({super.key, this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();
    final account = context.watch<AccountProvider>();

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          AppHeader(titleKey: 'home'),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('good_afternoon'),
                      style: AppTextStyles.label.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lara',
                      style: AppTextStyles.stepTitle.copyWith(fontSize: 26),
                    ),

                    const SizedBox(height: 24),

                    _BalanceCard(
                      account: account,
                      lang: lang,
                      onTap: () => Navigator.push(
                        context,
                        AppPageRoute(builder: (_) => const AccountsScreen()),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      lang.t('quick_actions'),
                      style: AppTextStyles.sectionTitle,
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _QuickAction(
                          icon: Icons.swap_horiz,
                          title: lang.t('transfer'),
                          onTap: () => Navigator.push(
                            context,
                            AppPageRoute(
                              builder: (_) => const TransferScreen(),
                            ),
                          ),
                        ),
                        _QuickAction(
                          icon: Icons.receipt_long,
                          title: lang.t('bills'),
                          onTap: () => onSelectTab?.call(1),
                        ),
                        _QuickAction(
                          icon: Icons.credit_card,
                          title: lang.t('cards'),
                          onTap: () => onSelectTab?.call(2),
                        ),
                        _QuickAction(
                          icon: Icons.widgets,
                          title: lang.t('products'),
                          onTap: () => onSelectTab?.call(3),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang.t('recent_transactions'),
                          style: AppTextStyles.sectionTitle,
                        ),
                        if (account.transactions.isNotEmpty)
                          Text(
                            lang.t('view_all'),
                            style: AppFonts.body(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    if (account.recentTransactions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              color: AppColors.textMuted,
                              size: 32,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              lang.t('no_transactions_yet'),
                              style: AppTextStyles.label,
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: AppColors.shadowRaised1,
                        ),
                        child: Column(
                          children: account.recentTransactions
                              .map((tx) => _TransactionRow(tx: tx, lang: lang))
                              .toList(),
                        ),
                      ),

                    const SizedBox(height: 24),

                    _AskAmeenBar(lang: lang, onTap: () => onSelectTab?.call(4)),

                    const SizedBox(height: 30),

                    Text('Offers for you', style: AppTextStyles.sectionTitle),

                    const SizedBox(height: 16),

                    _OfferCard(
                      icon: Icons.credit_card,
                      title: 'Visa Cards',
                      subtitle:
                          'Explore Classic, Gold, Platinum, and Signature cards.',
                      action: 'View cards',
                      onTap: () => onSelectTab?.call(2),
                    ),
                    const SizedBox(height: 12),
                    const _OfferCard(
                      icon: Icons.directions_car,
                      title: 'Car Finance',
                      subtitle: 'Flexible plans for new and used cars.',
                      action: 'Apply now',
                    ),
                    const SizedBox(height: 12),
                    const _OfferCard(
                      icon: Icons.home_work,
                      title: 'Property Finance',
                      subtitle: 'Finance your home or investment property.',
                      action: 'Learn more',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة الرصيد الرئيسية — تدرّج عمق حقيقي بظل متعدد المستويات،
/// مع رقم رصيد بخط Display بارز يحمل هوية التطبيق البصرية.
class _BalanceCard extends StatelessWidget {
  final AccountProvider account;
  final LangProvider lang;
  final VoidCallback onTap;

  const _BalanceCard({
    required this.account,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.cardGradient,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.shadowRaised2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(account.accountNumber, style: AppTextStyles.label),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold.withOpacity(0.35)),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: AppFonts.body(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(lang.t('total_balance'), style: AppTextStyles.label),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  account.balance.toStringAsFixed(2),
                  style: AppTextStyles.balanceDisplay,
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    account.currency,
                    style: AppFonts.body(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AskAmeenBar extends StatelessWidget {
  final LangProvider lang;
  final VoidCallback onTap;

  const _AskAmeenBar({required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primary.withOpacity(0.14), AppColors.card],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.mic, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 14),
            Text(
              lang.t('ask_ameen'),
              style: AppTextStyles.value.copyWith(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionModel tx;
  final LangProvider lang;

  const _TransactionRow({required this.tx, required this.lang});

  IconData get _icon {
    switch (tx.type) {
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.bill:
        return Icons.receipt_long;
      case TransactionType.cardIssuance:
        return Icons.credit_card;
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.direction == TransactionDirection.credit;
    final sign = isCredit ? '+' : '-';
    final color = isCredit ? AppColors.success : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t(tx.titleKey),
                  style: AppTextStyles.value.copyWith(fontSize: 14),
                ),
                if (tx.subtitle != null)
                  Text(
                    tx.subtitle!,
                    style: AppTextStyles.label.copyWith(fontSize: 12),
                  ),
              ],
            ),
          ),
          Text(
            '$sign${tx.amount.toStringAsFixed(2)}',
            style: AppFonts.body(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback? onTap;

  const _OfferCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$title selected')));
          },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.cardGradient,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.shadowRaised1,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              bottom: -8,
              child: Icon(icon, color: AppColors.cardBorder, size: 82),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.primary, size: 30),
                const SizedBox(height: 12),
                Text(title, style: AppTextStyles.sectionTitle),
                const SizedBox(height: 6),
                Text(subtitle, style: AppTextStyles.label),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _QuickAction({required this.icon, required this.title, this.onTap});

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: Column(
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _pressed ? 0.92 : 1.0,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.cardGradient,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppColors.shadowRaised1,
              ),
              child: Icon(widget.icon, color: AppColors.primary, size: 22),
            ),
          ),
          const SizedBox(height: 8),
          Text(widget.title, style: AppTextStyles.label.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
