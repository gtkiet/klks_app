import 'dart:math' as math;
import 'package:flutter/material.dart';

class EditAvatarScreen extends StatefulWidget {
  const EditAvatarScreen({super.key});

  @override
  State<EditAvatarScreen> createState() => _EditAvatarScreenState();
}

class _EditAvatarScreenState extends State<EditAvatarScreen> {
  Offset _dragOffset = Offset.zero;
  Offset _dragStart = Offset.zero;
  Offset _dragStartOffset = Offset.zero;
  double _rotation = 0.0;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    _buildCurrentAvatar(avatarUrl),
                    const SizedBox(height: 16),
                    const Text(
                      'Người dùng Smart Living',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ảnh đại diện giúp mọi người nhận ra bạn',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.camera_alt_rounded,
                            label: 'Chụp ảnh mới',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.photo_library_rounded,
                            label: 'Thư viện',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Text(
                          'Xem trước & Chỉnh sửa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const Spacer(),
                        _buildToolButton(
                          icon: Icons.rotate_left_rounded,
                          onTap: () => setState(() => _rotation -= 90),
                        ),
                        const SizedBox(width: 8),
                        _buildToolButton(
                          icon: Icons.rotate_right_rounded,
                          onTap: () => setState(() => _rotation += 90),
                        ),
                        const SizedBox(width: 8),
                        _buildToolButton(
                          icon: Icons.crop_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildCropBox(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Lưu thay đổi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
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
            'Chỉnh sửa ảnh đại diện',
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

  Widget _buildCurrentAvatar(String? avatarUrl) {
    final url = avatarUrl ?? "";
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: url.isNotEmpty
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _defaultAvatar();
                    },
                  )
                : _defaultAvatar(),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Icon(Icons.person, size: 64, color: Colors.white.withOpacity(0.9));
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF2563EB), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF374151)),
      ),
    );
  }

  Widget _buildCropBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 340,
        color: const Color(0xFF7A6050),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Draggable crop circle with placeholder photo
            GestureDetector(
              onPanStart: (d) {
                _dragStart = d.globalPosition;
                _dragStartOffset = _dragOffset;
              },
              onPanUpdate: (d) {
                setState(() {
                  _dragOffset =
                      _dragStartOffset + (d.globalPosition - _dragStart);
                  _dragOffset = Offset(
                    _dragOffset.dx.clamp(-80.0, 80.0),
                    _dragOffset.dy.clamp(-80.0, 80.0),
                  );
                });
              },
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: ClipOval(
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(_dragOffset.dx, _dragOffset.dy)
                      ..rotateZ(_rotation * math.pi / 180),
                    child: CustomPaint(
                      size: const Size(230, 230),
                      painter: _PhotoPlaceholderPainter(),
                    ),
                  ),
                ),
              ),
            ),

            // Phone frame overlay
            IgnorePointer(
              child: CustomPaint(
                size: const Size(175, 255),
                painter: _PhoneFramePainter(),
              ),
            ),

            // Drag hint label
            Positioned(
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'KÉO ĐỂ DI CHUYỂN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar illustration (small circle, top) ──────────────────────────────────

class _AvatarIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // BG
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFCFB89A),
    );

    // Body
    final body = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.8)
      ..quadraticBezierTo(w * 0.5, h * 0.65, w, h * 0.8)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF1C2D40));

    // Neck
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.66),
          width: w * 0.2,
          height: h * 0.13,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFDFA882),
    );

    // Head
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.4),
        width: w * 0.5,
        height: h * 0.52,
      ),
      Paint()..color = const Color(0xFFDFA882),
    );

    // Hair top
    final hair = Path()
      ..moveTo(w * 0.25, h * 0.36)
      ..quadraticBezierTo(w * 0.26, h * 0.15, w * 0.5, h * 0.14)
      ..quadraticBezierTo(w * 0.74, h * 0.15, w * 0.75, h * 0.36)
      ..quadraticBezierTo(w * 0.68, h * 0.2, w * 0.5, h * 0.19)
      ..quadraticBezierTo(w * 0.32, h * 0.2, w * 0.25, h * 0.36)
      ..close();
    canvas.drawPath(hair, Paint()..color = const Color(0xFF1A1A2E));

    // Eyes
    final ep = Paint()..color = const Color(0xFF2C1810);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.38, h * 0.4),
        width: w * 0.1,
        height: h * 0.06,
      ),
      ep,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.62, h * 0.4),
        width: w * 0.1,
        height: h * 0.06,
      ),
      ep,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Photo placeholder (large, inside crop box) ───────────────────────────────

class _PhotoPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Warm background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFF5D5C5), const Color(0xFFE8B89A)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Long hair left
    final hp = Paint()..color = const Color(0xFFBF8A45);
    final lHair = Path()
      ..moveTo(w * 0.2, h * 0.26)
      ..quadraticBezierTo(w * 0.04, h * 0.5, w * 0.07, h)
      ..lineTo(w * 0.28, h)
      ..quadraticBezierTo(w * 0.18, h * 0.55, w * 0.3, h * 0.3)
      ..close();
    canvas.drawPath(lHair, hp);

    // Long hair right
    final rHair = Path()
      ..moveTo(w * 0.8, h * 0.26)
      ..quadraticBezierTo(w * 0.96, h * 0.5, w * 0.93, h)
      ..lineTo(w * 0.72, h)
      ..quadraticBezierTo(w * 0.82, h * 0.55, w * 0.7, h * 0.3)
      ..close();
    canvas.drawPath(rHair, hp);

    // Top hair
    final tHair = Path()
      ..moveTo(w * 0.2, h * 0.28)
      ..quadraticBezierTo(w * 0.22, h * 0.07, w * 0.5, h * 0.05)
      ..quadraticBezierTo(w * 0.78, h * 0.07, w * 0.8, h * 0.28)
      ..quadraticBezierTo(w * 0.72, h * 0.11, w * 0.5, h * 0.1)
      ..quadraticBezierTo(w * 0.28, h * 0.11, w * 0.2, h * 0.28)
      ..close();
    canvas.drawPath(tHair, hp);

    // Face
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.34),
        width: w * 0.52,
        height: h * 0.48,
      ),
      Paint()..color = const Color(0xFFEABD9A),
    );

    // Shirt
    final shirt = Path()
      ..moveTo(w * 0.08, h)
      ..lineTo(w * 0.12, h * 0.77)
      ..quadraticBezierTo(w * 0.5, h * 0.67, w * 0.88, h * 0.77)
      ..lineTo(w * 0.92, h)
      ..close();
    canvas.drawPath(shirt, Paint()..color = const Color(0xFFF0EDE6));

    // Neck
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.615),
          width: w * 0.18,
          height: h * 0.1,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFFEABD9A),
    );

    // Eyes
    final ep = Paint()..color = const Color(0xFF5C3D2E);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.38, h * 0.33),
        width: w * 0.11,
        height: h * 0.065,
      ),
      ep,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.62, h * 0.33),
        width: w * 0.11,
        height: h * 0.065,
      ),
      ep,
    );

    // Lips
    final lips = Path()
      ..moveTo(w * 0.38, h * 0.435)
      ..quadraticBezierTo(w * 0.5, h * 0.46, w * 0.62, h * 0.435)
      ..quadraticBezierTo(w * 0.5, h * 0.48, w * 0.38, h * 0.435)
      ..close();
    canvas.drawPath(lips, Paint()..color = const Color(0xFFD4876A));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Phone frame overlay ───────────────────────────────────────────────────────

class _PhoneFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(22),
      ),
      paint,
    );

    // Home button
    canvas.drawCircle(
      Offset(w / 2, h - 13),
      9,
      Paint()
        ..color = Colors.black.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Front camera
    canvas.drawCircle(
      Offset(w / 2, 13),
      4,
      Paint()..color = Colors.black.withOpacity(0.45),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
