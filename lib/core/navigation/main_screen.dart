// lib/core/navigation/main_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/thong_bao/services/thong_bao_hub_service.dart';
import '../../features/thong_bao/widgets/thong_bao_nav_icon.dart';
import 'app_navigation.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainScreen({super.key, required this.shell});

  void _onTap(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
    if (index == 1) ThongBaoHubService.instance.resetUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    AppNavigation.setShell(shell);
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: shell.currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ThongBaoNavIcon(),
            activeIcon: ThongBaoNavIcon(isActive: true),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment_outlined),
            activeIcon: Icon(Icons.apartment),
            label: 'Cư trú',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
