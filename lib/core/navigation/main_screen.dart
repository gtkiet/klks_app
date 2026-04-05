// // lib/core/navigation/main_screen.dart

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import 'app_navigation.dart';

// class MainScreen extends StatelessWidget {
//   final StatefulNavigationShell shell;

//   const MainScreen({super.key, required this.shell});

//   void _onTap(int index) {
//     shell.goBranch(index, initialLocation: index == shell.currentIndex);
//   }

//   @override
//   Widget build(BuildContext context) {
//     /// 🔥 inject global shell
//     AppNavigation.setShell(shell);

//     return Scaffold(
//       body: shell,
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: shell.currentIndex,
//         onTap: _onTap,
//       ),
//     );
//   }
// }

// class BottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const BottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap,
//       type: BottomNavigationBarType.fixed,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home_outlined),
//           activeIcon: Icon(Icons.home),
//           label: 'Home',
//         ),
//                 BottomNavigationBarItem(
//           icon: Icon(Icons.apartment_outlined),
//           activeIcon: Icon(Icons.apartment),
//           label: 'Cư trú',
//         ),
//         // BottomNavigationBarItem(
//         //   icon: Icon(Icons.notifications_outlined),
//         //   activeIcon: Icon(Icons.notifications),
//         //   label: 'Thông báo',
//         // ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person_outline),
//           activeIcon: Icon(Icons.person),
//           label: 'Cá nhân',
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_navigation.dart';

import '../../design/shared/widgets/navigation/app_bottom_nav.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell shell;

  const MainScreen({super.key, required this.shell});

  void _onTap(int index) {
    shell.goBranch(
      index,
      initialLocation: index == shell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    /// 🔥 inject global shell
    AppNavigation.setShell(shell);

    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: shell.currentIndex,
        onTap: _onTap,
        items: const [
          AppNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          AppNavItem(
            icon: Icons.apartment_outlined,
            activeIcon: Icons.apartment,
            label: 'Cư trú',
          ),
          AppNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}