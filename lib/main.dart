import 'package:flutter/material.dart';
import 'features/ai/ai_screen.dart';
import 'features/bills/bills_screen.dart';
import 'features/home/home_screen.dart';
import 'features/products/products_screen.dart';

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

  static const _titles = [
    'Home',
    'Bills',
    'Products',
    'AI',
  ];

  static final _screens = [
    const HomeScreen(),
    const BillsScreen(),
    const ProductsScreen(),
    const AiScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        backgroundColor: const Color(0xFF141B24),
        selectedItemColor: const Color(0xFFD6A94A),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'AI',
          ),
        ],
      ),
    );
  }
}
