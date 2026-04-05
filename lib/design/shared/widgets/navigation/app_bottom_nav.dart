// lib/design/shared/widgets/navigation/app_bottom_nav.dart

import 'package:flutter/material.dart';
import '../../../constants/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppBottomNavigationBar
// ─────────────────────────────────────────────────────────────────────────────

/// Data class describing a single nav item.
class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Global bottom navigation bar.
///
/// Pass [items], the current [selectedIndex], and an [onTap] callback.
/// Active items are coloured [AppColors.primary]; inactive items use
/// [AppColors.secondary].
///
/// Example:
/// ```dart
/// Scaffold(
///   bottomNavigationBar: AppBottomNavigationBar(
///     selectedIndex: _tabIndex,
///     onTap: (i) => setState(() => _tabIndex = i),
///     items: const [
///       AppNavItem(
///         icon: Icons.home_outlined,
///         activeIcon: Icons.home_rounded,
///         label: 'Home',
///       ),
///       AppNavItem(
///         icon: Icons.receipt_long_outlined,
///         activeIcon: Icons.receipt_long_rounded,
///         label: 'Billing',
///       ),
///     ],
///   ),
/// )
/// ```
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  }) : assert(items.length >= 2 && items.length <= 5,
            'BottomNav requires 2–5 items');

  final List<AppNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.floating,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = i == selectedIndex;
              return _NavItem(
                item: item,
                isSelected: isSelected,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Private nav item ─────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.secondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  fontFamily: 'BeVietnamPro',
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}