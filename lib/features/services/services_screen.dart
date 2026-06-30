import 'package:flutter/material.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_header.dart';
import '../accounts/accounts_screen.dart';
import '../cards/screens/cards_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const _services = [
    _ServiceItem('Accounts', Icons.account_balance_wallet),
    _ServiceItem('Cards', Icons.credit_card),
    _ServiceItem('Finance', Icons.payments),
    _ServiceItem('Investment', Icons.trending_up),
    _ServiceItem('Saving Certificate', Icons.savings),
    _ServiceItem('Insurance', Icons.verified_user),
  ];

  void _openService(BuildContext context, _ServiceItem service) {
    final Widget? destination = switch (service.title) {
      'Accounts' => const AccountsScreen(),
      'Cards' => const CardsScreen(),
      _ => null,
    };

    if (destination != null) {
      Navigator.push(context, AppPageRoute(builder: (_) => destination));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${service.title} selected')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          const AppHeader(titleKey: 'services'),
          Expanded(
            child: SafeArea(
              top: false,
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _services.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 190,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final service = _services[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _openService(context, service),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.cardGradient,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: AppColors.shadowRaised1,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.inputFill,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(service.icon, color: AppColors.primary),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            service.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceItem {
  final String title;
  final IconData icon;

  const _ServiceItem(this.title, this.icon);
}
