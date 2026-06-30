import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'features/ai/ai_screen.dart';
import 'features/ai/transfer_assistant_sheet.dart';
import 'features/auth/login_screen.dart';
import 'features/bills/bills_screen.dart';
import 'features/home/home_screen.dart';
import 'features/products/products_screen.dart';
import 'features/transfer/transfer_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _titles = {0: 'Home', 2: 'Pay', 3: 'Store', 4: 'Servics'};

  static final _screens = {
    0: const HomeScreen(),
    2: const BillsScreen(),
    3: const ProductsScreen(),
    4: const AiScreen(),
  };

  void _onTabSelected(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TransferScreen()),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _openTransferAssistant() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF0B1117),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const TransferAssistantSheet(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_currentIndex != 0) {
      return AppBar(title: Text(_titles[_currentIndex]!));
    }

    return AppBar(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Good afternoon',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          Text(
            'Lara',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new notifications')),
            );
          },
        ),
        IconButton(
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _screens.keys.toList().indexOf(_currentIndex),
        children: _screens.values.toList(),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: const Color(0xFFD6A94A),
        foregroundColor: Colors.black,
        onPressed: _openTransferAssistant,
        child: const Icon(Icons.mic),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        backgroundColor: const Color(0xFF141B24),
        selectedItemColor: const Color(0xFFD6A94A),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Transfer',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Pay'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Store'),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Servics',
          ),
        ],
      ),
    );
  }
}
