import 'package:flutter/material.dart';
import '../bills/bills_screen.dart';
import '../transfer/transfer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 34),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'SA **** **** **** 9012',
                    style: TextStyle(color: Colors.white54),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '47,320.84 SAR',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QuickAction(
                  icon: Icons.swap_horiz,
                  title: 'Transfer',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransferScreen()),
                  ),
                ),
                _QuickAction(
                  icon: Icons.receipt_long,
                  title: 'Bills',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BillsFlowScreen()),
                  ),
                ),
                _QuickAction(icon: Icons.credit_card, title: 'Cards'),
                _QuickAction(icon: Icons.widgets, title: 'Products'),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Offers for you',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            const _AdvertisementCard(
              icon: Icons.credit_card,
              title: 'Visa Cards',
              subtitle: 'Explore Classic, Gold, Platinum, and Signature cards.',
              action: 'View cards',
            ),
            const SizedBox(height: 12),
            const _AdvertisementCard(
              icon: Icons.directions_car,
              title: 'Car Finance',
              subtitle: 'Flexible plans for new and used cars.',
              action: 'Apply now',
            ),
            const SizedBox(height: 12),
            const _AdvertisementCard(
              icon: Icons.home_work,
              title: 'Property Finance',
              subtitle: 'Finance your home or investment property.',
              action: 'Learn more',
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvertisementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;

  const _AdvertisementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141B24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(icon, color: Colors.white10, size: 82),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A241A),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Advertisement',
                  style: TextStyle(
                    color: Color(0xFFD6A94A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Icon(icon, color: const Color(0xFFD6A94A), size: 30),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    action,
                    style: const TextStyle(
                      color: Color(0xFFD6A94A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFFD6A94A),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _QuickAction({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF2A241A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFFD6A94A)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
