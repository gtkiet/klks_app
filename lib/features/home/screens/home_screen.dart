import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../../profile/services/profile_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? profile;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() {
      loading = true;
      error = null;
    });

    UserProfile? data;
    String? err;

    try {
      data = await ProfileService.getProfile();
    } catch (e) {
      err = "Không tải được dữ liệu";
    }

    if (!mounted) return;

    setState(() {
      profile = data;
      error = err;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error!),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: loadProfile,
                child: const Text("Thử lại"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(profile: profile),
                const SizedBox(height: 20),
                const _QuickActions(),
                const SizedBox(height: 20),
                const _MainContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =========================
/// 🔥 HEADER (DÙNG REAL DATA)
/// =========================
class _Header extends StatelessWidget {
  final UserProfile? profile;

  const _Header({this.profile});

  @override
  Widget build(BuildContext context) {
    final name = profile?.fullName.isNotEmpty == true
        ? profile!.fullName
        : "Người dùng";

    final avatarUrl = profile?.anhDaiDienUrl ?? "";

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: const Color(0xFFE5E7EB),
          backgroundImage:
              avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
          child: avatarUrl.isEmpty
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Xin chào 👋",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            // TODO: navigate to notifications
          },
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }
}

/// =========================
/// 🔥 QUICK ACTIONS
/// =========================
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        _ActionItem(
          icon: Icons.person_outline,
          label: "Hồ sơ",
        ),
        _ActionItem(
          icon: Icons.notifications_outlined,
          label: "Thông báo",
        ),
        _ActionItem(
          icon: Icons.settings_outlined,
          label: "Cài đặt",
        ),
        _ActionItem(
          icon: Icons.help_outline,
          label: "Hỗ trợ",
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: const Color(0xFF2563EB)),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =========================
/// 🔥 MAIN CONTENT
/// =========================
class _MainContent extends StatelessWidget {
  const _MainContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _InfoCard(
          title: "Thông tin tài khoản",
          content: "Xem và cập nhật thông tin cá nhân của bạn",
        ),
        SizedBox(height: 12),
        _InfoCard(
          title: "Tính năng mới",
          content: "Các tính năng mới sẽ được cập nhật tại đây",
        ),
        SizedBox(height: 12),
        _EmptyState(),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const _InfoCard({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// =========================
/// 🔥 EMPTY STATE
/// =========================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: Colors.grey,
          ),
          SizedBox(height: 10),
          Text(
            "Chưa có dữ liệu",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4),
          Text(
            "Hãy bắt đầu sử dụng ứng dụng",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}