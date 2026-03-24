// file: lib/layout/main_screen.dart

import 'package:flutter/material.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/home/screens/home_screen.dart';
import 'bottom_nav_bar.dart';

/// ─────────────────────────────────────────────────────────────
/// MainScreen (Optimized)
/// ─────────────────────────────────────────────────────────────
/// Root screen after authentication
/// Manages BottomNavigation + IndexedStack for tab persistence
/// Supports dynamic floatingActionButton per tab
/// ─────────────────────────────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  /// 🔥 Global key to control from outside
  static final GlobalKey<MainScreenState> navigatorKey =
      GlobalKey<MainScreenState>();

  /// 🔥 Public method to switch tab
  static void switchTab(int index) {
    navigatorKey.currentState?._setTab(index);
  }

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  /// Screens for each tab (final to avoid rebuilding each build)
  final List<Widget> _screens = const [
    HomeScreen(),
    _PlaceholderScreen(title: 'Bill'),
    _PlaceholderScreen(title: 'Service'),
    _PlaceholderScreen(title: 'Community'),
    ProfileScreen(),
  ];

  /// Optional: FloatingActionButton per tab
  final List<Widget?> _fabPerTab = [
    // FloatingActionButton(
    //   onPressed: () {},
    //   child: const Icon(Icons.add),
    // ), // Home tab
    null,
    null, // Bill
    null, // Service
    null, // Community
    null, // Profile
  ];

  /// INTERNAL: set tab
  void _setTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _setTab,
      ),
      floatingActionButton: _fabPerTab[_currentIndex],
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// PlaceholderScreen
/// ─────────────────────────────────────────────────────────────
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
