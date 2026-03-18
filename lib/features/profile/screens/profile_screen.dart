import 'package:flutter/material.dart';
import '../../../config/app_routes.dart';
import '../services/profile_service.dart';
import '../../../models/user_profile.dart';
import '../../auth/services/auth_service.dart';
import 'edit_profile_screen.dart';

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

    /// 👉 reload từ server để chắc chắn sync
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    /// 🔥 loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await _authService.logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

    if (profile == null) {
      return const Scaffold(body: Center(child: Text("Không có dữ liệu")));
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadProfile,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
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
            ),
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
          GestureDetector(
            onTap: _changeAvatar,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF5BA4A4),
              backgroundImage: profile!.anhDaiDienUrl.isNotEmpty
                  ? NetworkImage(profile!.anhDaiDienUrl)
                  : null,
              child: profile!.anhDaiDienUrl.isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile!.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            profile!.email,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _goToEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Chỉnh sửa hồ sơ'),
          ),
        ],
      ),
    );
  }

  // ================= BODY =================

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _section("THÔNG TIN CÁ NHÂN", [
            _row(Icons.badge_outlined, "CCCD", profile!.idCard),
            _row(Icons.person_outline, "Giới tính", profile!.gioiTinhName),
            _row(Icons.calendar_today, "Ngày sinh", profile!.formattedDob),
          ]),
          const SizedBox(height: 16),
          _section("LIÊN HỆ", [
            _row(Icons.phone, "SĐT", profile!.phoneNumber),
            _row(Icons.email, "Email", profile!.email),
            _row(Icons.home, "Địa chỉ", profile!.diaChi),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _logout, child: const Text("Đăng xuất")),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const Text(
            'Hồ sơ người dùng',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
