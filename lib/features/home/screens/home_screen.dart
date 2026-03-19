import 'package:flutter/material.dart';
import '../../../config/app_routes.dart';
import '../../../core/storage/user_session.dart';

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
    setState(() {}); // luôn lấy data mới từ UserSession
  }

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
                    _buildShortcuts(),
                    const SizedBox(height: 24),

                    // Hồ sơ & Căn hộ
                    _buildSectionLabel('HỒ SƠ & CĂN HỘ', color: const Color(0xFF2563EB)),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _MenuItem(icon: Icons.badge_outlined, label: 'Thông tin cá nhân'),
                      _MenuItem(icon: Icons.lock_reset_rounded, label: 'Thay đổi mật khẩu'),
                      _MenuItem(icon: Icons.apartment_rounded, label: 'Chi tiết căn hộ'),
                      _MenuItem(icon: Icons.group_outlined, label: 'Danh sách thành viên'),
                      _MenuItem(icon: Icons.directions_car_outlined, label: 'Phương tiện đăng ký', isLast: true),
                    ]),
                    const SizedBox(height: 24),

                    // Hóa đơn & Thanh toán
                    _buildSectionLabel('HÓA ĐƠN & THANH TOÁN', color: const Color(0xFF2563EB)),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _MenuItem(icon: Icons.receipt_long_outlined, label: 'Danh sách hóa đơn'),
                      _MenuItem(icon: Icons.account_balance_wallet_outlined, label: 'Chi tiết phí'),
                      _MenuItem(icon: Icons.payment_rounded, label: 'Thanh toán & Ủy nhiệm chi'),
                      _MenuItem(icon: Icons.history_rounded, label: 'Lịch sử giao dịch', isLast: true),
                    ]),
                    const SizedBox(height: 24),

                    // Dịch vụ & Tiện ích
                    _buildSectionLabel('DỊCH VỤ & TIỆN ÍCH', color: const Color(0xFF2563EB)),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _MenuItem(icon: Icons.build_outlined, label: 'Tạo yêu cầu sửa chữa', badge: 'MỚI', badgeColor: const Color(0xFF2563EB)),
                      _MenuItem(icon: Icons.format_list_bulleted_rounded, label: 'Theo dõi tiến độ'),
                      _MenuItem(icon: Icons.event_available_outlined, label: 'Đăng ký tiện ích chung', isLast: true),
                    ]),
                    const SizedBox(height: 24),

                    // Cộng đồng & Thông báo
                    _buildSectionLabel('CỘNG ĐỒNG & THÔNG BÁO', color: const Color(0xFF2563EB)),
                    const SizedBox(height: 12),
                    _buildMenuCard([
                      _MenuItem(icon: Icons.notifications_outlined, label: 'Xem thông báo mới'),
                      _MenuItem(icon: Icons.how_to_vote_outlined, label: 'Khảo sát & Bầu cử cư dân'),
                      _MenuItem(icon: Icons.support_agent_rounded, label: 'Hỗ trợ Virtual Assistant', badge: 'AI', badgeColor: const Color(0xFF6B7280), isLast: true),
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
            backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
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
                const Text('XIN CHÀO,', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                Text(user.fullName ?? 'Người dùng', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const Icon(Icons.notifications_outlined),
        ],
      ),
    );
  }

  // ================= TITLE =================
  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800));
  }

  // ================= SHORTCUT =================
  void _showPlaceholder(String title) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Text('$title đang được phát triển'),
      ),
    );
  }

  Widget _buildShortcuts() {
    final items = [
      _ShortcutItem(icon: Icons.home_work_rounded, label: 'Căn hộ\nCủa tôi', route: AppRoutes.residences),
      _ShortcutItem(icon: Icons.receipt_long_rounded, label: 'Thanh toán\nHóa đơn'),
      _ShortcutItem(icon: Icons.build_rounded, label: 'Yêu cầu\nKỹ thuật'),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (item.route != null && AppRoutes.routes.containsKey(item.route)) {
                Navigator.pushNamed(context, item.route!);
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
                  child: Icon(item.icon, size: 32, color: const Color(0xFF2563EB)),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================= MENU CARD =================
  Widget _buildSectionLabel(String text, {Color color = const Color(0xFF6B7280)}) {
    return Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.8));
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
            _showPlaceholder(item.label);
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
                  child: Icon(
                    item.icon,
                    size: 18,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                if (item.badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (item.badgeColor ?? const Color(0xFF2563EB)).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.badge!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: item.badgeColor ?? const Color(0xFF2563EB),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(Icons.chevron_right_rounded, size: 18, color: const Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
        if (!item.isLast)
          Divider(height: 1, thickness: 1, indent: 66, endIndent: 16, color: const Color(0xFFF3F4F6)),
      ],
    );
  }
}

// ================= DATA MODELS =================
class _ShortcutItem {
  final IconData icon;
  final String label;
  final String? route;
  const _ShortcutItem({required this.icon, required this.label, this.route});
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeColor,
    this.isLast = false,
  });
}