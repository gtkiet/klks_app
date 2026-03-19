import 'package:flutter/material.dart';
import '../../../core/storage/user_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _lightOn = true;
  bool _acOn = true;

  final PageController _notifController = PageController();

  @override
  void dispose() {
    _notifController.dispose();
    super.dispose();
  }

  // 🔥 KEY FIX: rebuild khi quay lại màn hình
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // đảm bảo luôn lấy data mới từ UserSession
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(user),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildWeatherRow(),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Lối tắt nhanh'),
                    const SizedBox(height: 14),
                    _buildShortcuts(),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Trạng thái căn hộ'),
                        const Text(
                          'Tất cả',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
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
            backgroundImage: (user.avatarUrl != null &&
                    user.avatarUrl!.isNotEmpty)
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
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
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

  // ================= WEATHER =================
  Widget _buildWeatherRow() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nhiệt độ", style: TextStyle(color: Colors.white70)),
                SizedBox(height: 10),
                Text(
                  '28°C',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Không khí"),
                SizedBox(height: 10),
                Text(
                  'Tốt',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= TITLE =================
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // ================= SHORTCUT =================
  Widget _buildShortcuts() {
    final items = [
      Icons.lightbulb,
      Icons.credit_card,
      Icons.design_services,
      Icons.person_add,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items
          .map(
            (icon) => Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon),
                ),
                const SizedBox(height: 8),
                const Text("Item"),
              ],
            ),
          )
          .toList(),
    );
  }

  // ================= DEVICE =================
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  // ================= NOTIFICATION =================
  Widget _buildNotifications() {
    final items = [
      "Thông báo 1",
      "Thông báo 2",
      "Thông báo 3",
    ];

    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _notifController,
        itemCount: items.length,
        itemBuilder: (_, i) =>
            Card(child: Center(child: Text(items[i]))),
      ),
    );
  }
}