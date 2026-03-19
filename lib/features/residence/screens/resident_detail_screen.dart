import 'package:flutter/material.dart';
import '../../../widgets/app_button.dart';
import '../services/residence_service.dart';

class ResidentDetailScreen extends StatefulWidget {
  final int userId;
  final int quanHeCuTruId;

  const ResidentDetailScreen({
    super.key,
    required this.userId,
    required this.quanHeCuTruId,
  });

  @override
  State<ResidentDetailScreen> createState() => _ResidentDetailScreenState();
}

class _ResidentDetailScreenState extends State<ResidentDetailScreen> {
  final ResidenceService _service = ResidenceService();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await _service.getResidentDetail(
      userId: widget.userId,
      quanHeCuTruId: widget.quanHeCuTruId,
    );

    if (result['success']) {
      setState(() {
        _data = result['data'];
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['message'];
        _loading = false;
      });
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '--';
    try {
      final date = DateTime.parse(iso);
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Chi tiết cư dân'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 1,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _buildError();
    return _buildContent();
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
          const SizedBox(height: 12),
          SubmitButton(
            label: 'Thử lại',
            onPressed: _fetchData,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final d = _data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          _buildHeader(d),
          const SizedBox(height: 24),
          _buildSection(
            title: 'THÔNG TIN CÁ NHÂN',
            children: [
              _buildItem('Họ tên', d['fullName']),
              _buildItem('SĐT', d['phoneNumber']),
              _buildItem('CCCD', d['idCard']),
              _buildItem('Ngày sinh', _formatDate(d['dob'])),
              _buildItem('Giới tính', d['gioiTinhName']),
              _buildItem('Vai trò', d['roleName']),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'THÔNG TIN CƯ TRÚ',
            children: [
              _buildItem('Loại quan hệ', d['loaiQuanHeTen'], badge: true),
              _buildItem('Ngày bắt đầu', _formatDate(d['ngayBatDau'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> d) {
    final avatar = d['anhDaiDienUrl'];
    final role = d['roleName'] ?? '--';

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFFD1D5DB),
              backgroundImage:
                  (avatar != null && avatar.isNotEmpty) ? NetworkImage(avatar) : null,
              child: (avatar == null || avatar.isEmpty)
                  ? const Icon(Icons.person, size: 48, color: Colors.white)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          d['fullName'] ?? '--',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          role,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
                fontSize: 13,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildItem(String label, dynamic value, {bool badge = false}) {
    final content = value?.toString() ?? '--';
    if (badge) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D4ED8),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              content,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}