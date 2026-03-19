import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/app_routes.dart';
import '../../../models/user_profile.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()..loadProfile()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer2<ProfileProvider, AuthProvider>(
        builder: (context, profileProvider, authProvider, _) {
          if (profileProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (profileProvider.error != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(profileProvider.error!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: profileProvider.refresh,
                      child: const Text("Thử lại"),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = profileProvider.profile;
          if (profile == null) {
            return const Scaffold(
              body: Center(child: Text("Không có dữ liệu")),
            );
          }

          return Scaffold(
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: profileProvider.refresh,
                child: Column(
                  children: [
                    _buildAppBar(context),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            _buildHeader(context, profileProvider, profile),
                            const SizedBox(height: 16),
                            _buildBody(context, profileProvider, authProvider, profile),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= APP BAR =================
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

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context, ProfileProvider provider, UserProfile profile) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async => await _changeAvatar(context, provider),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF5BA4A4),
              backgroundImage: profile.anhDaiDienUrl.isNotEmpty
                  ? NetworkImage(profile.anhDaiDienUrl)
                  : null,
              child: profile.anhDaiDienUrl.isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(profile.email, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async => await _goToEdit(context, provider, profile),
            icon: const Icon(Icons.edit),
            label: const Text('Chỉnh sửa hồ sơ'),
          ),
        ],
      ),
    );
  }

  // ================= BODY =================
  Widget _buildBody(
    BuildContext context,
    ProfileProvider profileProvider,
    AuthProvider authProvider,
    UserProfile profile,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _section("THÔNG TIN CÁ NHÂN", [
            _row(Icons.badge_outlined, "CCCD", profile.idCard),
            _row(Icons.person_outline, "Giới tính", profile.gioiTinhName),
            _row(Icons.calendar_today, "Ngày sinh", profile.formattedDob),
          ]),
          const SizedBox(height: 16),
          _section("LIÊN HỆ", [
            _row(Icons.phone, "SĐT", profile.phoneNumber),
            _row(Icons.email, "Email", profile.email),
            _row(Icons.home, "Địa chỉ", profile.diaChi),
          ]),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: authProvider.isLoggingOut
                ? null
                : () async => await authProvider.logout(),
            child: authProvider.isLoggingOut
                ? const CircularProgressIndicator()
                : const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================
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

  // ================= NAVIGATION =================
  Future<void> _goToEdit(BuildContext context, ProfileProvider provider, UserProfile profile) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: profile)),
    );

    if (updated != null && updated is UserProfile) {
      provider.updateLocalProfile(updated); // update Provider ngay
    }
  }

  Future<void> _changeAvatar(BuildContext context, ProfileProvider provider) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.editAvatar,
      arguments: provider.profile?.anhDaiDienUrl,
    );

    if (result != null) {
      await provider.loadProfile(force: true); // reload avatar mới
    }
  }
}