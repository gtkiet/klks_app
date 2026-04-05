// lib/features/residence/widgets/request_tab.dart

import 'package:flutter/material.dart';

import '../screens/request_detail_screen.dart';
import '../services/residence_service.dart';
import '../../../../core/errors/app_exception.dart';

import '../models/residence_request.dart';

class RequestTab extends StatefulWidget {
  final int canHoId;

  const RequestTab({super.key, required this.canHoId});

  @override
  State<RequestTab> createState() => _RequestTabState();
}

class _RequestTabState extends State<RequestTab>
    with AutomaticKeepAliveClientMixin {
  final _service = ResidenceService.instance;

  bool _loading = true;
  String? _error;
  List<ResidenceRequestItem> _requests = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.getRequestList(
        pageNumber: 1,
        pageSize: 50,
        canHoId: widget.canHoId,
      );
      setState(() => _requests = result.items);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    if (_requests.isEmpty) {
      return const Center(child: Text('Chưa có yêu cầu nào'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _requests.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final req = _requests[i];
          return _RequestCard(
            request: req,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RequestDetailScreen(requestId: req.id),
              ),
            ).then((_) => _load()),
            // onTap: () => context
            //     .push('/residence/request/${req.id}')
            //     .then((_) => _load()),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ResidenceRequestItem request;
  final VoidCallback onTap;

  const _RequestCard({required this.request, required this.onTap});

  Color _statusColor(int trangThaiId) {
    switch (trangThaiId) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text('${request.tenLoaiYeuCau} · #${request.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gửi bởi: ${request.tenNguoiGui}'),
            Text(
              '${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(request.trangThaiId).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            request.tenTrangThai,
            style: TextStyle(
              color: _statusColor(request.trangThaiId),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
