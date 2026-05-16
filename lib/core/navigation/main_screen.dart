// lib/core/navigation/main_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:klks_app/features/thong_bao/services/thong_bao_hub_service.dart';
import 'package:klks_app/features/thong_bao/widgets/thong_bao_nav_icon.dart';

import 'app_navigation.dart';

class MainScreen extends StatefulWidget {
  final StatefulNavigationShell shell;
  const MainScreen({super.key, required this.shell});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppNavigation.setShell(widget.shell);
    AppNavigation.setRouter(GoRouter.of(context));
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Shell instance có thể thay đổi khi GoRouter rebuild.
    if (oldWidget.shell != widget.shell) {
      AppNavigation.setShell(widget.shell);
    }
  }

  void _onTap(int index) {
    widget.shell.goBranch(
      index,
      initialLocation: index == widget.shell.currentIndex,
    );
    if (index == 1) ThongBaoHubService.instance.resetUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.shell.currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: ThongBaoNavIcon(),
            activeIcon: ThongBaoNavIcon(isActive: true),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets_outlined),
            activeIcon: Icon(Icons.widgets),
            label: 'Dịch vụ',
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
