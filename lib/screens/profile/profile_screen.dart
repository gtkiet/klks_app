import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../services/profile_service.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await ProfileService.getProfile();

    setState(() {
      profile = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // White header section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: Column(
                      children: [
                        _buildAvatar(),
                        const SizedBox(height: 16),
                        Text(
                          "${profile!.firstName} ${profile!.lastName}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile!.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildEditButton(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Personal info section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('THÔNG TIN CÁ NHÂN'),
                        const SizedBox(height: 10),
                        _buildInfoCard([
                          _InfoRow(
                            icon: Icons.badge_outlined,
                            label: 'SỐ CMND/CCCD',
                            value: profile!.idCard,
                          ),
                          _InfoRow(
                            icon: Icons.person_outline_rounded,
                            label: 'GIỚI TÍNH',
                            value: profile!.gioiTinhName,
                          ),
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'NGÀY SINH',
                            value: profile!.dob,
                            isLast: true,
                          ),
                        ]),
                        const SizedBox(height: 20),

                        _buildSectionLabel('LIÊN HỆ'),
                        const SizedBox(height: 10),
                        _buildInfoCard([
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'SỐ ĐIỆN THOẠI',
                            value: profile!.phoneNumber,
                          ),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'EMAIL',
                            value: profile!.email,
                          ),
                          _InfoRow(
                            icon: Icons.apartment_rounded,
                            label: 'ĐỊA CHỈ',
                            value: profile!.diaChi,
                            isLast: true,
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // Logout
                        _buildLogoutButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────

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
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF111827),
                size: 24,
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const Text(
            'Hồ sơ người dùng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = profile?.anhDaiDienUrl ?? "";

    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF5BA4A4),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
          ),
          child: ClipOval(
            child: avatarUrl.isNotEmpty
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _defaultAvatar();
                    },
                  )
                : _defaultAvatar(),
          ),
        ),

        /// camera button
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.editAvatar, arguments: profile?.anhDaiDienUrl);
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Icon(Icons.person, size: 64, color: Colors.white.withOpacity(0.9));
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF374151),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: rows.map((row) => _buildInfoRowWidget(row)).toList(),
      ),
    );
  }

  Widget _buildInfoRowWidget(_InfoRow row) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(row.icon, color: const Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      row.value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!row.isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 70,
            endIndent: 16,
            color: const Color(0xFFF3F4F6),
          ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: const [
                Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
                SizedBox(width: 12),
                Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Data models ─────────────────────────────────────────────────────────────

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });
}
