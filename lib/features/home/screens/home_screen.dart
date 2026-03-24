// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routes/app_routes.dart';
import '../../../layout/main_screen.dart';
import '../../../core/widgets/widgets.dart';
import '../services/home_service.dart';
import '../models/home_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final _controller = _HomeController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _controller.init();
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() async {
    await _controller.refresh();
    if (mounted) setState(() {});
  }

  void _navigate(String route) {
    switch (route) {
      case AppRoutes.home:
        MainScreen.switchTab(0);
        return;
      case AppRoutes.bill:
        MainScreen.switchTab(1);
        return;
      case AppRoutes.service:
        MainScreen.switchTab(2);
        return;
      case AppRoutes.community:
        MainScreen.switchTab(3);
        return;
      case AppRoutes.profile:
        MainScreen.switchTab(4);
        return;
      default:
        context.push(route);
    }
  }

  void _handleTap(String? route, String label) {
    if (route != null) {
      _navigate(route);
    } else {
      showModalBottomSheet(
        context: context,
        builder: (_) => Padding(
          padding: const EdgeInsets.all(20),
          child: AppText.body('$label đang được phát triển'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_controller.isLoading) return const _LoadingView();
    if (_controller.error != null) {
      return _ErrorView(message: _controller.error!, onRetry: _init);
    }

    final data = _controller.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(data: data),
                const SizedBox(height: 20),
                const _SectionTitle('Lối tắt nhanh'),
                const SizedBox(height: 14),
                _ShortcutGrid(
                  items: const [
                    _ShortcutItem(
                      icon: Icons.home_work_rounded,
                      label: 'Căn hộ\nCủa tôi',
                      route: AppRoutes.residences,
                    ),
                    _ShortcutItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'Thanh toán\nHóa đơn',
                      route: AppRoutes.bill,
                    ),
                    _ShortcutItem(
                      icon: Icons.build_rounded,
                      label: 'Yêu cầu\nKỹ thuật',
                      route: AppRoutes.service,
                    ),
                  ],
                  onTap: _handleTap,
                ),
                const SizedBox(height: 24),
                _buildSection('HỒ SƠ & CĂN HỘ', [
                  _MenuItem(
                    icon: Icons.badge_outlined,
                    label: 'Thông tin cá nhân',
                    route: AppRoutes.profile,
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
                _buildSection('HÓA ĐƠN & THANH TOÁN', [
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Danh sách hóa đơn',
                    route: AppRoutes.bill,
                  ),
                  _MenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Chi tiết phí',
                    route: AppRoutes.bill,
                  ),
                  _MenuItem(
                    icon: Icons.payment_rounded,
                    label: 'Thanh toán',
                    route: AppRoutes.bill,
                  ),
                  _MenuItem(
                    icon: Icons.history_rounded,
                    label: 'Lịch sử giao dịch',
                    route: AppRoutes.bill,
                    isLast: true,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('DỊCH VỤ & TIỆN ÍCH', [
                  _MenuItem(
                    icon: Icons.build_outlined,
                    label: 'Tạo yêu cầu sửa chữa',
                    route: AppRoutes.service,
                  ),
                  _MenuItem(
                    icon: Icons.format_list_bulleted_rounded,
                    label: 'Theo dõi tiến độ',
                    route: AppRoutes.service,
                  ),
                  _MenuItem(
                    icon: Icons.event_available_outlined,
                    label: 'Đăng ký tiện ích',
                    isLast: true,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('CỘNG ĐỒNG & THÔNG BÁO', [
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Thông báo',
                    route: AppRoutes.community,
                  ),
                  _MenuItem(
                    icon: Icons.how_to_vote_outlined,
                    label: 'Khảo sát',
                    route: AppRoutes.community,
                  ),
                  _MenuItem(
                    icon: Icons.support_agent_rounded,
                    label: 'Virtual Assistant',
                    isLast: true,
                  ),
                ]),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Logout',
                  onPressed: _controller.logout,
                  type: AppButtonType.danger,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<_MenuItem> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _SectionLabel(title),
      const SizedBox(height: 12),
      _MenuCard(items: items, onTap: _handleTap),
    ],
  );
}

/// ================= CONTROLLER =================
class _HomeController {
  final HomeService _service = HomeService();

  bool isLoading = true;
  String? error;
  HomeData? data;

  Future<void> init() async {
    try {
      isLoading = true;
      error = null;
      data = await _service.getHomeData();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  Future<void> refresh() async {
    try {
      error = null;
      data = await _service.getHomeData();
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> logout() async => await _service.logout();
}

/// ================= UI COMPONENTS =================
class _TopBar extends StatelessWidget {
  final HomeData? data;
  const _TopBar({this.data});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: data?.avatarUrl != null
                ? NetworkImage(data!.avatarUrl!)
                : null,
            child: data?.avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.body('XIN CHÀO'),
                AppText(
                  data?.fullName ?? 'Người dùng',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Icon(Icons.notifications_outlined),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => AppText.title(text);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => AppText.title(text);
}

/// ================= SHORTCUT GRID =================
class _ShortcutGrid extends StatelessWidget {
  final List<_ShortcutItem> items;
  final Function(String?, String) onTap;
  const _ShortcutGrid({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: items.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.9,
    ),
    itemBuilder: (context, index) {
      final e = items[index];
      return GestureDetector(
        onTap: () => onTap(e.route, e.label),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(e.icon, size: 32, color: const Color(0xFF2563EB)),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                e.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  final Function(String?, String) onTap;
  const _MenuCard({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Column(
      children: items
          .map(
            (e) => Column(
              children: [
                ListTile(
                  leading: Icon(e.icon),
                  title: AppText.body(e.label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onTap(e.route, e.label),
                ),
                if (!e.isLast) const Divider(height: 1),
              ],
            ),
          )
          .toList(),
    ),
  );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.body(message),
          const SizedBox(height: 16),
          AppButton(text: 'Retry', onPressed: onRetry),
        ],
      ),
    ),
  );
}

/// ================= MODELS =================
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
  final bool isLast;
  const _MenuItem({
    required this.icon,
    required this.label,
    this.route,
    this.isLast = false,
  });
}
