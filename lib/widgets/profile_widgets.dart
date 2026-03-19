import 'package:flutter/material.dart';

/// ── MODEL ───────────────────────────────
class InfoRow {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });
}

/// ── AVATAR WIDGET ───────────────────────
class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.size = 80,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder ? Border.all(color: Colors.blueAccent, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          image: imageUrl != null && imageUrl!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          color: imageUrl == null ? Colors.grey[200] : null,
        ),
        child: imageUrl == null || imageUrl!.isEmpty
            ? Icon(
                Icons.person,
                size: size * 0.5,
                color: Colors.grey[500],
              )
            : null,
      ),
    );
  }
}

/// ── BUTTONS ─────────────────────────────
class EditProfileButton extends StatelessWidget {
  final VoidCallback onPressed;
  const EditProfileButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.edit_rounded, size: 18),
        label: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const LogoutButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: const [
                Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
                SizedBox(width: 12),
                Text(
                  'Đăng xuất',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ── SECTION LABEL ───────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
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
}

/// ── INFO CARD ───────────────────────────
class InfoCard extends StatelessWidget {
  final List<InfoRow> rows;
  const InfoCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: rows.map((row) => InfoRowWidget(row: row)).toList(),
      ),
    );
  }
}

class InfoRowWidget extends StatelessWidget {
  final InfoRow row;
  const InfoRowWidget({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
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
                    Text(row.label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        )),
                    const SizedBox(height: 3),
                    Text(row.value,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                          height: 1.4,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!row.isLast)
          Divider(height: 1, thickness: 1, indent: 70, endIndent: 16, color: const Color(0xFFF3F4F6)),
      ],
    );
  }
}