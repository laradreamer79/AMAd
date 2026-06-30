import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/ai/ai_screen.dart';
import 'features/bills/bills_screen.dart';
import 'features/home/home_screen.dart';
import 'features/products/products_screen.dart';
import 'features/cards/providers/cards_provider.dart';
import 'features/cards/screens/cards_screen.dart';
import 'core/navigation/app_page_route.dart';
import 'core/theme/app_colors.dart';
import 'core/i18n/lang_provider.dart';
import 'features/account/providers/account_provider.dart';
import 'features/transfer/providers/transfer_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/lock_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/services/services_screen.dart';
import 'core/widgets/animated_bottom_nav.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const AmeenApp());
}

class AmeenApp extends StatelessWidget {
  const AmeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CardsProvider()),
        ChangeNotifierProvider(create: (_) => LangProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => TransferProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<LangProvider>(
        builder: (context, langProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Ameen',
            locale: langProvider.locale,
            theme: ThemeData(
              textTheme: langProvider.isRTL
                  ? GoogleFonts.ibmPlexSansArabicTextTheme(
                      ThemeData.dark().textTheme,
                    )
                  : GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
              scaffoldBackgroundColor: AppColors.background,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
            ),
            builder: (context, child) {
              return Directionality(
                textDirection: langProvider.direction,
                child: child!,
              );
            },
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return auth.isLocked ? const LockScreen() : const MainScreen();
              },
            ),
          );
        },
      ),
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

  List<Widget> get _screens => [
    HomeScreen(onSelectTab: _onTabSelected),
    const BillsScreen(),
    const CardsScreen(),
    const ProductsScreen(),
    const ServicesScreen(),
    const ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openAi() {
    Navigator.push(context, AppPageRoute(builder: (_) => const AiScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LangProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        heroTag: 'global-ai-assistant',
        tooltip: lang.t('ai'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _openAi,
        child: const Icon(Icons.mic),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: [
          NavItemData(icon: Icons.home, label: lang.t('home')),
          NavItemData(icon: Icons.receipt_long, label: lang.t('bills')),
          NavItemData(icon: Icons.credit_card, label: lang.t('cards')),
          NavItemData(icon: Icons.widgets, label: lang.t('products')),
          NavItemData(icon: Icons.grid_view, label: lang.t('services')),
          NavItemData(icon: Icons.person_outline, label: lang.t('profile')),
        ],
      ),
    );
  }
}
