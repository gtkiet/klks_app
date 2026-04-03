// lib/features/cu_tru/screens/thanh_vien_cu_tru_screen.dart
//
// Screen 2: Danh sách thành viên đang ở trong căn hộ.
// Nhấn vào thành viên để xem hồ sơ chi tiết (ThongTinCuDanScreen).

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/thanh_vien_cu_tru_model.dart';
import '../models/thong_tin_cu_dan_model.dart';
import '../services/cu_tru_service.dart';

class ThanhVienCuTruScreen extends StatefulWidget {
  final int canHoId;
  final String tenCanHo;

  const ThanhVienCuTruScreen({
    super.key,
    required this.canHoId,
    required this.tenCanHo,
  });

  @override
  State<ThanhVienCuTruScreen> createState() => _ThanhVienCuTruScreenState();
}

class _ThanhVienCuTruScreenState extends State<ThanhVienCuTruScreen> {
  final _service = CuTruService();

  List<ThanhVienCuTruModel> _list = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _service.getThanhVienCuTru(widget.canHoId);
      setState(() => _list = result);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thành viên - ${widget.tenCanHo}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_list.isEmpty) {
      return const Center(
        child: Text(
          'Không có thành viên nào đang cư trú.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _list.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) => _ThanhVienTile(
          item: _list[i],
          onTap: () => _openDetail(_list[i].quanHeCuTruId),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }

  void _openDetail(int quanHeCuTruId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThongTinCuDanScreen(quanHeCuTruId: quanHeCuTruId),
      ),
    );
  }
}

// ─── Tile ─────────────────────────────────────────────────────────────────────

class _ThanhVienTile extends StatelessWidget {
  final ThanhVienCuTruModel item;
  final VoidCallback onTap;

  const _ThanhVienTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ngay = item.ngayBatDau != null
        ? DateFormat('dd/MM/yyyy').format(item.ngayBatDau!)
        : '---';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: item.anhDaiDienUrl != null
            ? NetworkImage(item.anhDaiDienUrl!)
            : null,
        child: item.anhDaiDienUrl == null
            ? Text(
                item.fullName.isNotEmpty ? item.fullName[0].toUpperCase() : '?',
              )
            : null,
      ),
      title: Text(
        item.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('${item.loaiQuanHeTen} · Từ $ngay'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

// ─── Chi tiết hồ sơ cư dân ───────────────────────────────────────────────────

class ThongTinCuDanScreen extends StatefulWidget {
  final int quanHeCuTruId;

  const ThongTinCuDanScreen({super.key, required this.quanHeCuTruId});

  @override
  State<ThongTinCuDanScreen> createState() => _ThongTinCuDanScreenState();
}

class _ThongTinCuDanScreenState extends State<ThongTinCuDanScreen> {
  final _service = CuTruService();

  ThongTinCuDanModel? _data;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _service.getThongTinCuDan(widget.quanHeCuTruId);
      setState(() => _data = result);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cư dân')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    if (_data == null) return const SizedBox();

    final d = _data!;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + tên
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: d.anhDaiDienUrl != null
                      ? NetworkImage(d.anhDaiDienUrl!)
                      : null,
                  child: d.anhDaiDienUrl == null
                      ? Text(
                          d.fullName.isNotEmpty
                              ? d.fullName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  d.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Chip(label: Text(d.trangThaiCuTruTen)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _SectionTitle('Thông tin cá nhân'),
          _InfoRow('Giới tính', d.gioiTinhName),
          _InfoRow(
            'Ngày sinh',
            d.dob != null ? dateFormat.format(d.dob!) : '---',
          ),
          _InfoRow('CCCD / CMND', d.idCard ?? '---'),
          _InfoRow('Điện thoại', d.phoneNumber ?? '---'),
          _InfoRow('Địa chỉ', d.diaChi ?? '---'),

          const SizedBox(height: 16),
          _SectionTitle('Thông tin cư trú'),
          _InfoRow('Quan hệ cư trú', d.loaiQuanHeTen),
          _InfoRow(
            'Ngày bắt đầu',
            d.ngayBatDau != null ? dateFormat.format(d.ngayBatDau!) : '---',
          ),
          _InfoRow(
            'Ngày kết thúc',
            d.ngayKetThuc != null
                ? dateFormat.format(d.ngayKetThuc!)
                : 'Hiện tại',
          ),

          if (d.taiLieuCuTrus.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionTitle('Tài liệu đính kèm (${d.taiLieuCuTrus.length})'),
            ...d.taiLieuCuTrus.map(
              (doc) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.tenLoaiGiayTo,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text('Số: ${doc.soGiayTo}'),
                      if (doc.ngayPhatHanh != null)
                        Text(
                          'Ngày phát hành: ${dateFormat.format(doc.ngayPhatHanh!)}',
                        ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: doc.files
                            .map(
                              (f) => ActionChip(
                                label: Text(
                                  f.fileName,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onPressed: () {
                                  /* TODO: mở file */
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
