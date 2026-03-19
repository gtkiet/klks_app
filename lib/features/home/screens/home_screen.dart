import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_profile.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/providers/profile_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider()..loadProfile(),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.error != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.error!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: provider.refresh,
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = provider.profile;

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F5),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: provider.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(),
                      const SizedBox(height: 20),
                      _QuickActions(),
                      const SizedBox(height: 20),
                      const _MainContent(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// =========================
/// 🔥 HEADER
/// =========================
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    final profile = provider.profile;
    final name = (profile?.fullName.isNotEmpty == true) ? profile!.fullName : "Người dùng";
    final avatarUrl = profile?.anhDaiDienUrl ?? "";

    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            if (profile != null) {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              if (updated != null && updated is UserProfile) {
                provider.updateLocalProfile(updated);
              }
            }
          },
          child: CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFE5E7EB),
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),
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
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);
    final profile = provider.profile;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _ActionItem(
          icon: Icons.person_outline,
          label: "Hồ sơ",
          onTap: () async {
            if (profile != null) {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              if (updated != null && updated is UserProfile) {
                provider.updateLocalProfile(updated);
              }
            }
          },
        ),
        _ActionItem(
          icon: Icons.notifications_outlined,
          label: "Thông báo",
          onTap: () {},
        ),
        _ActionItem(
          icon: Icons.settings_outlined,
          label: "Cài đặt",
          onTap: () {},
        ),
        _ActionItem(
          icon: Icons.help_outline,
          label: "Hỗ trợ",
          onTap: () {},
        ),
      ],
    );
  }
}

/// =========================
/// 🔥 ACTION ITEM
/// =========================
class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
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