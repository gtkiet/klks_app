import 'package:flutter/material.dart';

import '../features/profile/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentTab = 0;

  /// =========================
  /// 🔥 NAV CONFIG (SINGLE SOURCE)
  /// =========================
  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.home_rounded,
      label: 'Trang chủ',
      page: Center(child: Text("Home")),
    ),
    _NavItem(
      icon: Icons.person_rounded,
      label: 'Cá nhân',
      page: ProfileScreen(),
    ),
  ];

  /// =========================
  /// 🔥 BACK HANDLING (ANDROID)
  /// =========================
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
        body: IndexedStack(
          index: _currentTab,
          children: _navItems.map((e) => e.page).toList(),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
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
            children: List.generate(_navItems.length, (i) {
              final item = _navItems[i];
              final active = i == _currentTab;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentTab = i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 26,
                        color: active
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: active
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
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

class _NavItem {
  final IconData icon;
  final String label;
  final Widget page;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}