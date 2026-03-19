import 'package:flutter/material.dart';

import '../features/profile/screens/profile_screen.dart';
import '../features/home/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentTab = 0;
  late final PageController _pageController;

  // =========================
  // CONFIG
  // =========================
  static const _activeColor = Color(0xFF2563EB);
  static const _inactiveColor = Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // =========================
  // NAV ITEMS (DÙNG BUILDER)
  // =========================
  List<_NavItem> get _navItems => [
        const _NavItem(icon: Icons.home_rounded, label: 'Trang chủ', builder: HomeScreen.new),
        _NavItem(icon: Icons.receipt_long_rounded, label: 'Hóa đơn', builder: _placeholderBuilder('Hóa đơn')),
        _NavItem(icon: Icons.build_rounded, label: 'Dịch vụ', builder: _placeholderBuilder('Dịch vụ')),
        _NavItem(icon: Icons.group_outlined, label: 'Cộng đồng', builder: _placeholderBuilder('Cộng đồng')),
        const _NavItem(icon: Icons.person_rounded, label: 'Cá nhân', builder: ProfileScreen.new),
      ];

  static Widget Function() _placeholderBuilder(String title) {
    return () => Center(
          child: Text(
            '$title đang phát triển',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        );
  }

  // =========================
  // BACK HANDLING (ANDROID)
  // =========================
  Future<bool> _onWillPop() async {
    if (_currentTab != 0) {
      setState(() => _currentTab = 0);
      _pageController.jumpToPage(0);
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
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _navItems.map((e) => e.builder()).toList(),
        ),
        bottomNavigationBar: _BottomNavBar(
          items: _navItems,
          currentIndex: _currentTab,
          onTap: (index) {
            if (index == _currentTab) return;
            setState(() => _currentTab = index);
            _pageController.jumpToPage(index);
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
  final Widget Function() builder;

  const _NavItem({required this.icon, required this.label, required this.builder});
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
                  child: _NavBarItemWidget(item: item, isActive: isActive),
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
// NAV ITEM WIDGET
// =========================
class _NavBarItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isActive;

  const _NavBarItemWidget({required this.item, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, size: 26, color: isActive ? _MainScreenState._activeColor : _MainScreenState._inactiveColor),
        const SizedBox(height: 4),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? _MainScreenState._activeColor : _MainScreenState._inactiveColor,
          ),
        ),
      ],
    );
  }
}