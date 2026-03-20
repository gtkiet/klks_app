import 'package:flutter/material.dart';

import '../features/profile/screens/profile_screen.dart';
import '../features/home/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // =========================
  // GLOBAL CONTROL (CHO APP ROUTES)
  // =========================
  static final GlobalKey<MainScreenState> navigatorKey =
      GlobalKey<MainScreenState>();

  static void switchTab(int index) {
    navigatorKey.currentState?.switchTab(index);
  }

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentTab = 0;

  // =========================
  // CONFIG
  // =========================
  static const _activeColor = Color(0xFF2563EB);
  static const _inactiveColor = Color(0xFF9CA3AF);

  // =========================
  // PUBLIC METHOD (CHO ROUTE GỌI)
  // =========================
  void switchTab(int index) {
    if (_currentTab == index) return;
    setState(() => _currentTab = index);
  }

  // =========================
  // NAV ITEMS (GIỮ INSTANCE)
  // =========================
  late final List<_NavItem> _navItems = [
    const _NavItem(
      icon: Icons.home_rounded,
      label: 'Trang chủ',
      screen: HomeScreen(),
    ),
    const _NavItem(
      icon: Icons.receipt_long_rounded,
      label: 'Hóa đơn',
      screen: _PlaceholderScreen(title: 'Hóa đơn'),
    ),
    const _NavItem(
      icon: Icons.build_rounded,
      label: 'Dịch vụ',
      screen: _PlaceholderScreen(title: 'Dịch vụ'),
    ),
    const _NavItem(
      icon: Icons.group_outlined,
      label: 'Cộng đồng',
      screen: _PlaceholderScreen(title: 'Cộng đồng'),
    ),
    const _NavItem(
      icon: Icons.person_rounded,
      label: 'Cá nhân',
      screen: ProfileScreen(),
    ),
  ];

  // =========================
  // BACK HANDLING
  // =========================
  Future<bool> _onWillPop() async {
    if (_currentTab != 0) {
      setState(() => _currentTab = 0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,

        // ✅ GIỮ STATE CÁC TAB
        body: IndexedStack(
          index: _currentTab,
          children: _navItems.map((e) => e.screen).toList(),
        ),

        bottomNavigationBar: _BottomNavBar(
          items: _navItems,
          currentIndex: _currentTab,
          onTap: (index) {
            if (index == _currentTab) return;
            setState(() => _currentTab = index);
          },
        ),
      ),
    );
  }
}

// =========================
// NAV ITEM MODEL
// =========================
class _NavItem {
  final IconData icon;
  final String label;
  final Widget screen;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}

// =========================
// PLACEHOLDER SCREEN
// =========================
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title đang phát triển',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// =========================
// CUSTOM BOTTOM NAV BAR
// =========================
class _BottomNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: _NavBarItemWidget(
                    item: item,
                    isActive: isActive,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// =========================
// NAV ITEM UI
// =========================
class _NavBarItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isActive;

  const _NavBarItemWidget({
    required this.item,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: isActive
          ? BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            size: 26,
            color: isActive
                ? MainScreenState._activeColor
                : MainScreenState._inactiveColor,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive
                  ? MainScreenState._activeColor
                  : MainScreenState._inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}