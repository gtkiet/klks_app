// features/home/screens/home_screen.dart (old)

import 'package:flutter/material.dart';
import '../../../config/app_routes.dart';
import '../../../core/storage/user_session.dart';
import '../../../layout/main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _notifController = PageController();

  @override
  void dispose() {
    _notifController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  // ================= NAVIGATION CORE =================
  void _navigate(String route) {
    switch (route) {
      // ===== TAB =====
      case AppRoutes.homeTab:
        MainScreen.switchTab(0);
        return;

      case AppRoutes.billTab:
        MainScreen.switchTab(1);
        return;

      case AppRoutes.serviceTab:
        MainScreen.switchTab(2);
        return;

      case AppRoutes.communityTab:
        MainScreen.switchTab(3);
        return;

      case AppRoutes.profileTab:
        MainScreen.switchTab(4);
        return;

      // ===== NORMAL SCREEN =====
      default:
        Navigator.pushNamed(context, route);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final user = UserSession();

    return Container(
      color: const Color(0xFFF3F4F6),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(user),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle('Lối tắt nhanh'),
                    const SizedBox(height: 14),
                    _buildShortcuts([
                      _ShortcutItem(
                        icon: Icons.home_work_rounded,
                        label: 'Căn hộ\nCủa tôi',
                        route: AppRoutes.residences,
                      ),
                      _ShortcutItem(
                        icon: Icons.receipt_long_rounded,
                        label: 'Thanh toán\nHóa đơn',
                        route: AppRoutes.billTab,
                      ),
                      _ShortcutItem(
                        icon: Icons.build_rounded,
                        label: 'Yêu cầu\nKỹ thuật',
                        route: AppRoutes.serviceTab,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // ================= HỒ SƠ =================
                    _buildSectionLabel(
                      'HỒ SƠ & CĂN HỘ',
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _MenuItem(
                        icon: Icons.badge_outlined,
                        label: 'Thông tin cá nhân',
                        route: AppRoutes.profileTab,
                      ),
                      _MenuItem(
                        icon: Icons.lock_reset_rounded,
                        label: 'Thay đổi mật khẩu',
                        route: AppRoutes.changePassword,
                      ),
                      _MenuItem(
                        icon: Icons.apartment_rounded,
                        label: 'Danh sách cư trú',
                        route: AppRoutes.residences,
                      ),
                      _MenuItem(
                        icon: Icons.directions_car_outlined,
                        label: 'Phương tiện đăng ký',
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // ================= HÓA ĐƠN =================
                    _buildSectionLabel(
                      'HÓA ĐƠN & THANH TOÁN',
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _MenuItem(
                        icon: Icons.receipt_long_outlined,
                        label: 'Danh sách hóa đơn',
                        route: AppRoutes.billTab,
                      ),
                      _MenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Chi tiết phí',
                        route: AppRoutes.billTab,
                      ),
                      _MenuItem(
                        icon: Icons.payment_rounded,
                        label: 'Thanh toán & Ủy nhiệm chi',
                        route: AppRoutes.billTab,
                      ),
                      _MenuItem(
                        icon: Icons.history_rounded,
                        label: 'Lịch sử giao dịch',
                        route: AppRoutes.billTab,
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // ================= DỊCH VỤ =================
                    _buildSectionLabel(
                      'DỊCH VỤ & TIỆN ÍCH',
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _MenuItem(
                        icon: Icons.build_outlined,
                        label: 'Tạo yêu cầu sửa chữa',
                        route: AppRoutes.serviceTab,
                        badge: 'MỚI',
                        badgeColor: const Color(0xFF2563EB),
                      ),
                      _MenuItem(
                        icon: Icons.format_list_bulleted_rounded,
                        label: 'Theo dõi tiến độ',
                        route: AppRoutes.serviceTab,
                      ),
                      _MenuItem(
                        icon: Icons.event_available_outlined,
                        label: 'Đăng ký tiện ích chung',
                        route: AppRoutes.serviceTab,
                        isLast: true,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // ================= CỘNG ĐỒNG =================
                    _buildSectionLabel(
                      'CỘNG ĐỒNG & THÔNG BÁO',
                      color: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Xem thông báo mới',
                        route: AppRoutes.communityTab,
                      ),
                      _MenuItem(
                        icon: Icons.how_to_vote_outlined,
                        label: 'Khảo sát & Bầu cử cư dân',
                        route: AppRoutes.communityTab,
                      ),
                      _MenuItem(
                        icon: Icons.support_agent_rounded,
                        label: 'Hỗ trợ Virtual Assistant',
                        badge: 'AI',
                        badgeColor: const Color(0xFF6B7280),
                        isLast: true,
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TOP BAR =================
  Widget _buildTopBar(UserSession user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFCBD5E1),
            backgroundImage:
                (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                ? Icon(Icons.person, color: Colors.grey[500])
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'XIN CHÀO,',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
                Text(
                  user.fullName ?? 'Người dùng',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.notifications_outlined),
        ],
      ),
    );
  }

  // ================= COMMON UI =================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }

  void _showPlaceholder(String title) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Text('$title đang được phát triển'),
      ),
    );
  }

  Widget _buildShortcuts(List<_ShortcutItem> items) {
    return Row(
      children: items.map((item) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (item.route != null) {
                _navigate(item.route!);
              } else {
                _showPlaceholder(item.label);
              }
            },
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item.icon,
                    size: 32,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionLabel(
    String text, {
    Color color = const Color(0xFF6B7280),
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(children: items.map(_buildMenuRow).toList()),
    );
  }

  Widget _buildMenuRow(_MenuItem item) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (item.route != null) {
              _navigate(item.route!);
            } else {
              _showPlaceholder(item.label);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(item.icon, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(item.label, style: const TextStyle(fontSize: 15)),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
        if (!item.isLast) const Divider(indent: 66, endIndent: 16, height: 1),
      ],
    );
  }
}

// ================= MODELS =================
class _ShortcutItem {
  final IconData icon;
  final String label;
  final String? route;

  const _ShortcutItem({required this.icon, required this.label, this.route});
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? route;
  final String? badge;
  final Color? badgeColor;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.route,
    this.badge,
    this.badgeColor,
    this.isLast = false,
  });
}
