import 'package:flutter/material.dart';

import '../screens/profile/profile_screen.dart';

// import '../screens/home/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentTab = 0;

  final _pages = const [
    Center(child: Text("Home")),
    Center(child: Text("Smart Home")),
    Center(child: Text("Dịch vụ")),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: _currentTab, children: _pages),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      const _NavItem(icon: Icons.home_rounded, label: 'Trang chủ'),
      const _NavItem(icon: Icons.router_rounded, label: 'Smart Home'),
      const _NavItem(icon: Icons.apps_rounded, label: 'Dịch vụ'),
      const _NavItem(icon: Icons.person_rounded, label: 'Cá nhân'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == _currentTab;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentTab = i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].icon,
                        size: 26,
                        color: active
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
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

  const _NavItem({required this.icon, required this.label});
}
