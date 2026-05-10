// lib/features/phan_anh/screens/phan_anh_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/errors/errors.dart';
import '../models/phan_anh_model.dart';
import '../services/phan_anh_service.dart';

class PhanAnhDetailScreen extends StatefulWidget {
  final int phanAnhId;

  const PhanAnhDetailScreen({super.key, required this.phanAnhId});

  @override
  State<PhanAnhDetailScreen> createState() => _PhanAnhDetailScreenState();
}

class _PhanAnhDetailScreenState extends State<PhanAnhDetailScreen> {
  final _service = PhanAnhService.instance;
  final _chatCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  PhanAnhDetailResponse? _detail;
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  @override
  void dispose() {
    _chatCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final detail = await _service.getById(widget.phanAnhId);
      setState(() => _detail = detail);
      // Scroll to bottom after render
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on AppException catch (e) {
      setState(() => _errorMsg = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendChat() async {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;

    // TODO: validate max length

    setState(() => _isSending = true);
    try {
      await _service.submitTraLoi(
        phanAnhId: widget.phanAnhId,
        noiDung: text,
      );
      _chatCtrl.clear();
      await _fetchDetail();
    } on AppException catch (e) {
      _showError(e.message);
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _withdraw() async {
    final confirmed = await _confirmDialog(
      title: 'Thu hồi phản ánh',
      content: 'Bạn có chắc muốn thu hồi phản ánh này không?',
    );
    if (!confirmed) return;

    setState(() => _isSending = true);
    try {
      await _service.withdraw(widget.phanAnhId);
      _showSuccess('Đã thu hồi phản ánh.');
      await _fetchDetail();
    } on AppException catch (e) {
      _showError(e.message);
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _openRatingDialog() async {
    if (_detail == null) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RatingDialog(
        phanAnhId: widget.phanAnhId,
        service: _service,
        onDone: () {
          Navigator.pop(context);
          _fetchDetail();
        },
      ),
    );
  }

  Future<bool> _confirmDialog(
      {required String title, required String content}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xác nhận')),
        ],
      ),
    );
    return result ?? false;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_detail?.tieuDe ?? 'Chi tiết phản ánh',
            overflow: TextOverflow.ellipsis),
        actions: _buildActions(),
      ),
      body: _buildBody(),
    );
  }

  List<Widget> _buildActions() {
    if (_detail == null) return [];
    final status = _detail!.trangThaiPhanAnhId;
    return [
      // Cư dân thu hồi khi đang chờ tiếp nhận
      if (status == 1)
        TextButton(
          onPressed: _isSending ? null : _withdraw,
          child: const Text('Thu hồi', style: TextStyle(color: Colors.white)),
        ),
      // Cư dân đánh giá khi chờ đánh giá
      if (status == 5)
        TextButton(
          onPressed: _isSending ? null : _openRatingDialog,
          child:
              const Text('Đánh giá', style: TextStyle(color: Colors.white)),
        ),
    ];
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
                onPressed: _fetchDetail, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    final d = _detail!;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    // Show chat input if ticket is active (not done/cancelled/draft)
    final canChat = ![6, 7, 8].contains(d.trangThaiPhanAnhId);

    return Column(
      children: [
        // ── Main scrollable content ──────────────────────────────────────
        Expanded(
          child: ListView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(16),
            children: [
              // ── Info card ──────────────────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow('Căn hộ', d.tenCanHo),
                      _InfoRow('Loại', d.loaiPhanAnhTen),
                      _InfoRow('Trạng thái', d.trangThaiPhanAnhTen),
                      if (d.tenNguoiXuLy != null)
                        _InfoRow('Người xử lý', d.tenNguoiXuLy!),
                      _InfoRow('Ngày tạo', fmt.format(d.createdAt.toLocal())),
                      _InfoRow('Người gửi', d.tenNguoiGui),
                      if (d.noiDung != null && d.noiDung!.isNotEmpty) ...[
                        const Divider(height: 20),
                        Text(d.noiDung!,
                            style: TextStyle(color: Colors.grey[800])),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Rating result (if done) ────────────────────────────────
              if (d.trangThaiPhanAnhId == 6 && d.diemDanhGia != null) ...[
                const SizedBox(height: 12),
                Card(
                  color: const Color(0xFFE6FFED),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Đánh giá của cư dân',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < d.diemDanhGia!
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ),
                        if (d.nhanXetDanhGia != null &&
                            d.nhanXetDanhGia!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(d.nhanXetDanhGia!),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Attachments ───────────────────────────────────────────
              if (d.danhSachTep.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Tệp đính kèm',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ...d.danhSachTep.map(
                  (f) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.attach_file),
                    title: Text(f.fileName, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(f.fileUrl,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                    // TODO: tap to open/download file
                  ),
                ),
              ],

              // ── Chat history ─────────────────────────────────────────
              if (d.traLoiPhanAnhs.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Trao đổi',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...d.traLoiPhanAnhs.map(
                  (t) => _ChatBubble(traLoi: t),
                ),
              ],

              const SizedBox(height: 8),
            ],
          ),
        ),

        // ── Chat input ───────────────────────────────────────────────────
        if (canChat)
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: const Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatCtrl,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSending
                      ? const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.send),
                          color: Theme.of(context).primaryColor,
                          onPressed: _sendChat,
                        ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Supporting widgets ───────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style:
                    TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final TraLoiPhanAnh traLoi;

  const _ChatBubble({required this.traLoi});

  @override
  Widget build(BuildContext context) {
    final isStaff = traLoi.isNhanVien;
    final fmt = DateFormat('HH:mm dd/MM');
    return Align(
      alignment: isStaff ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isStaff
              ? const Color(0xFFEBF8FF)
              : const Color(0xFFEBF8F0),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isStaff ? 4 : 16),
            bottomRight: Radius.circular(isStaff ? 16 : 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              traLoi.tenNguoiGui,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isStaff
                      ? Colors.blue[700]
                      : Colors.green[700]),
            ),
            const SizedBox(height: 2),
            Text(traLoi.noiDung, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 2),
            Text(
              fmt.format(traLoi.createdAt.toLocal()),
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Rating dialog ────────────────────────────────────────────────────────────

class _RatingDialog extends StatefulWidget {
  final int phanAnhId;
  final PhanAnhService service;
  final VoidCallback onDone;

  const _RatingDialog({
    required this.phanAnhId,
    required this.service,
    required this.onDone,
  });

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _stars = 0;
  final _commentCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_stars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn số sao đánh giá.')));
      return;
    }
    // TODO: validate min comment length if needed

    setState(() => _isSubmitting = true);
    try {
      await widget.service.danhGia(
        phanAnhId: widget.phanAnhId,
        diemDanhGia: _stars,
        nhanXetDanhGia: _commentCtrl.text.trim(),
      );
      widget.onDone();
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đánh giá chất lượng xử lý'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Chọn số sao:', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _stars = i + 1),
                child: Icon(
                  i < _stars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentCtrl,
            decoration: const InputDecoration(
              hintText: 'Nhận xét (không bắt buộc)...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Gửi đánh giá'),
        ),
      ],
    );
  }
}