import 'package:flutter/material.dart';

import '../../../config/app_routes.dart';
import '../services/profile_service.dart';
import '../../../models/user_profile.dart';
import '../../auth/services/auth_service.dart';
import 'edit_profile_screen.dart';
import '../../../widgets/profile_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? profile;
  bool loading = true;
  String? error;
  final AuthService _authService = AuthService();

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

  Future<void> _goToEdit() async {
    if (profile == null) return;

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: profile!)),
    );

    if (updated != null && mounted) {
      setState(() => profile = updated);
    }
  }

  Future<void> _changeAvatar() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.editAvatar,
      arguments: profile?.anhDaiDienUrl,
    );

    if (result != null) {
      await loadProfile();
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn đăng xuất không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Đăng xuất")),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await _authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(error!),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: loadProfile, child: const Text("Thử lại")),
          ],
        ),
      );
    }
    if (profile == null) return const Center(child: Text("Không có dữ liệu"));

    return RefreshIndicator(
      onRefresh: loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _changeAvatar,
            child: AvatarWidget(size: 100, onTap: _changeAvatar, imageUrl: profile!.anhDaiDienUrl),
          ),
          const SizedBox(height: 16),
          Text(profile!.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(profile!.email, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 20),
          EditProfileButton(onPressed: _goToEdit),
        ],
      ),
    );
  }

  // ================= BODY =================
  Widget _buildBody() {
    final personalInfo = [
      InfoRow(icon: Icons.badge_outlined, label: "CCCD", value: profile!.idCard),
      InfoRow(icon: Icons.person_outline, label: "Giới tính", value: profile!.gioiTinhName),
      InfoRow(icon: Icons.calendar_today, label: "Ngày sinh", value: profile!.formattedDob, isLast: true),
    ];

    final contactInfo = [
      InfoRow(icon: Icons.phone, label: "SĐT", value: profile!.phoneNumber),
      InfoRow(icon: Icons.email, label: "Email", value: profile!.email),
      InfoRow(icon: Icons.home, label: "Địa chỉ", value: profile!.diaChi, isLast: true),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SectionLabel(text: "THÔNG TIN CÁ NHÂN"),
          const SizedBox(height: 8),
          InfoCard(rows: personalInfo),
          const SizedBox(height: 16),
          SectionLabel(text: "LIÊN HỆ"),
          const SizedBox(height: 8),
          InfoCard(rows: contactInfo),
          const SizedBox(height: 20),
          LogoutButton(onTap: _logout),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}