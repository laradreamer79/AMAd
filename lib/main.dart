import 'package:flutter/material.dart';
import 'features/ai/ai_screen.dart';
import 'features/bills/bills_screen.dart';
import 'features/home/home_screen.dart';
import 'features/products/products_screen.dart';
import 'features/transfer/transfer_screen.dart';

void main() {
  runApp(const AmeenApp());
}

class AmeenApp extends StatelessWidget {
  const AmeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ameen',
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFF0B1117),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD6A94A),
          brightness: Brightness.dark,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

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
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Signed out')));
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
