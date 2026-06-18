import 'package:flutter/material.dart';

import '../accounts/accounts_screen.dart';

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  static const _services = [
    _ServiceItem('Accounts', Icons.account_balance_wallet),
    _ServiceItem('Cards', Icons.credit_card),
    _ServiceItem('Finance', Icons.payments),
    _ServiceItem('Investment', Icons.trending_up),
    _ServiceItem('Saving Certificate', Icons.savings),
    _ServiceItem('Insurance', Icons.verified_user),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (service.title == 'Accounts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountsScreen()),
                );
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${service.title} selected')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141B24),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A241A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(service.icon, color: const Color(0xFFD6A94A)),
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
    );
  }
}

class _ServiceItem {
  final String title;
  final IconData icon;

  const _ServiceItem(this.title, this.icon);
}
