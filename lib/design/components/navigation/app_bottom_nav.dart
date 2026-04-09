import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/typography.dart';
import '../../tokens/elevation.dart';

/// Navigation item model.
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

/// PKK Resident - App Bottom Navigation Bar
///
/// Global bottom nav used across main tab screens.
///
/// Usage:
/// ```dart
/// AppBottomNavigationBar(
///   currentIndex: _tabIndex,
///   onTap: (i) => setState(() => _tabIndex = i),
///   items: const [
///     AppNavItem(icon: Icons.home_outlined,    activeIcon: Icons.home,    label: 'Home'),
///     AppNavItem(icon: Icons.receipt_outlined, activeIcon: Icons.receipt, label: 'Billing'),
///     AppNavItem(icon: Icons.bolt_outlined,    activeIcon: Icons.bolt,    label: 'Services'),
///     AppNavItem(icon: Icons.event_outlined,   activeIcon: Icons.event,   label: 'Events'),
///     AppNavItem(icon: Icons.person_outlined,  activeIcon: Icons.person,  label: 'Profile'),
///   ],
/// )
/// ```
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppElevation.level2,
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: _NavItem(
                  item: item,
                  isActive: isActive,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final AppNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.secondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              key: ValueKey(isActive),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: AppTypography.captionSmall.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
