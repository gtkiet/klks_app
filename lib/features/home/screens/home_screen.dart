import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  bool _lightOn = true;
  bool _acOn = true;
  int _notificationPage = 0;

  final PageController _notifController = PageController();

  @override
  void dispose() {
    _notifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            _buildTopBar(),
            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Weather + Air row
                    _buildWeatherRow(),
                    const SizedBox(height: 24),

                    // Quick shortcuts
                    _buildSectionTitle('Lối tắt nhanh'),
                    const SizedBox(height: 14),
                    _buildShortcuts(),
                    const SizedBox(height: 24),

                    // Apartment status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Trạng thái căn hộ'),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Tất cả',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildDeviceCard(
                      icon: Icons.lightbulb_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      iconBg: const Color(0xFFFEF3C7),
                      title: 'Hệ thống đèn',
                      subtitle: '3 thiết bị đang bật',
                      value: _lightOn,
                      onChanged: (v) => setState(() => _lightOn = v),
                    ),
                    const SizedBox(height: 12),
                    _buildDeviceCard(
                      icon: Icons.ac_unit_rounded,
                      iconColor: const Color(0xFF2563EB),
                      iconBg: const Color(0xFFEFF6FF),
                      title: 'Điều hòa (PK)',
                      subtitle: 'Đang chạy • 25°C',
                      value: _acOn,
                      onChanged: (v) => setState(() => _acOn = v),
                    ),
                    const SizedBox(height: 24),

                    // BQL notifications
                    _buildSectionTitle('Thông báo từ BQL'),
                    const SizedBox(height: 14),
                    _buildNotifications(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFCBD5E1),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
            ),
            child: ClipOval(
              child: Icon(Icons.person, size: 30, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(width: 12),
          // Greeting
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'XIN CHÀO,',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Anh Minh',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          // Bell
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3F4F6),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: Color(0xFF374151), size: 24),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherRow() {
    return Row(
      children: [
        // Temperature card
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.thermostat_rounded,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Nhiệt độ',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  '28°C',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ngoài trời: 32°C',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Air quality card
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.air_rounded,
                        color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Không khí',
                      style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tốt',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'AQI 45',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildShortcuts() {
    final shortcuts = [
      _ShortcutItem(
        icon: Icons.lightbulb_outline_rounded,
        secondIcon: Icons.home_outlined,
        label: 'Smart Home',
        bg: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF4F46E5),
      ),
      _ShortcutItem(
        icon: Icons.credit_card_rounded,
        label: 'Thanh toán',
        bg: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF059669),
      ),
      _ShortcutItem(
        icon: Icons.design_services_rounded,
        label: 'Dịch vụ',
        bg: const Color(0xFFFFF7ED),
        iconColor: const Color(0xFFEA580C),
      ),
      _ShortcutItem(
        icon: Icons.person_add_rounded,
        label: 'Khách',
        bg: const Color(0xFFFAF5FF),
        iconColor: const Color(0xFF9333EA),
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: shortcuts.map((s) => _buildShortcutItem(s)).toList(),
    );
  }

  Widget _buildShortcutItem(_ShortcutItem item) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: item.bg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(item.icon, color: item.iconColor, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF2563EB),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DB),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    final notifications = [
      _NotifItem(
        title: 'Bảo trì thang máy Tháp A',
        body:
            'Thời gian: 09:00 – 11:00 ngày 25/10. Vui lòng sử dụng thang máy Tháp B trong thời gian này.',
      ),
      _NotifItem(
        title: 'Họp cư dân tháng 11',
        body:
            'Buổi họp cư dân định kỳ sẽ được tổ chức vào 19:00 ngày 05/11 tại hội trường tầng 2.',
      ),
      _NotifItem(
        title: 'Vệ sinh bể bơi',
        body:
            'Bể bơi tầng 5 sẽ tạm ngưng hoạt động từ 08:00 – 12:00 ngày 28/10 để vệ sinh định kỳ.',
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _notifController,
            itemCount: notifications.length,
            onPageChanged: (i) => setState(() => _notificationPage = i),
            itemBuilder: (_, i) => _buildNotifCard(notifications[i]),
          ),
        ),
        const SizedBox(height: 12),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(notifications.length, (i) {
            final active = i == _notificationPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildNotifCard(_NotifItem item) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'i',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Trang chủ'),
      _NavItem(icon: Icons.router_rounded, label: 'Smart Home'),
      _NavItem(icon: Icons.apps_rounded, label: 'Dịch vụ'),
      _NavItem(icon: Icons.person_rounded, label: 'Cá nhân'),
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

// ── Data models ─────────────────────────────────────────────────────────────

class _ShortcutItem {
  final IconData icon;
  final IconData? secondIcon;
  final String label;
  final Color bg;
  final Color iconColor;

  const _ShortcutItem({
    required this.icon,
    this.secondIcon,
    required this.label,
    required this.bg,
    required this.iconColor,
  });
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NotifItem {
  final String title;
  final String body;
  const _NotifItem({required this.title, required this.body});
}