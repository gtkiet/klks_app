// lib/features/residence/screens/create_request_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/member.dart';
import '../models/residence_apartment.dart';
import '../models/selector_item.dart';
import '../services/residence_service.dart';
import '../../../../core/errors/app_exception.dart';
import 'request_form_screen.dart';



class CreateRequestScreen extends StatefulWidget {
  final ResidenceApartment apartment;

  const CreateRequestScreen({super.key, required this.apartment});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _service = ResidenceService.instance;

  bool _loadingTypes = true;
  List<SelectorItem> _loaiYeuCau = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    try {
      final items = await _service.getLoaiYeuCau();
      setState(() => _loaiYeuCau = items);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loadingTypes = false);
    }
  }

  void _onSelectType(SelectorItem type) async {
    // loaiYeuCauId: 1=Thêm, 2=Sửa, 3=Xóa
    if (type.id == 1) {
      // Thêm: vào form ngay
      _goToForm(loaiYeuCau: type, targetMember: null, memberDetail: null);
    } else {
      // Sửa / Xóa: phải chọn thành viên trước
      final result = await _showMemberPicker(type);
      if (result != null && mounted) {
        _goToForm(
          loaiYeuCau: type,
          targetMember: result.$1,
          memberDetail: result.$2,
        );
      }
    }
  }

  Future<(Member, MemberDetail)?> _showMemberPicker(
      SelectorItem loaiYeuCau) async {
    return showModalBottomSheet<(Member, MemberDetail)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MemberPickerSheet(
        canHoId: widget.apartment.canHoId,
        service: _service,
      ),
    );
  }

  void _goToForm({
    required SelectorItem loaiYeuCau,
    required Member? targetMember,
    required MemberDetail? memberDetail,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestFormScreen(
          apartment: widget.apartment,
          loaiYeuCau: loaiYeuCau,
          targetMember: targetMember,
          prefillDetail: memberDetail,
        ),
      ),
    ).then((_) {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn loại yêu cầu')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loadingTypes) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _loaiYeuCau.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final type = _loaiYeuCau[i];
        final icon = switch (type.id) {
          1 => Icons.person_add,
          2 => Icons.edit,
          3 => Icons.person_remove,
          _ => Icons.help_outline,
        };
        final color = switch (type.id) {
          1 => Colors.green,
          2 => Colors.blue,
          3 => Colors.red,
          _ => Colors.grey,
        };
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.1),
            foregroundColor: color,
            padding: const EdgeInsets.all(20),
            side: BorderSide(color: color.withValues(alpha: 0.4)),
          ),
          onPressed: () => _onSelectType(type),
          icon: Icon(icon, size: 28),
          label: Text(
            type.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }
}

// ─── Member Picker Bottom Sheet ───────────────────────────────────────────────

class _MemberPickerSheet extends StatefulWidget {
  final int canHoId;
  final ResidenceService service;

  const _MemberPickerSheet({
    required this.canHoId,
    required this.service,
  });

  @override
  State<_MemberPickerSheet> createState() => _MemberPickerSheetState();
}

class _MemberPickerSheetState extends State<_MemberPickerSheet> {
  bool _loading = true;
  String? _error;
  List<Member> _members = [];
  int? _loadingMemberId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.service.getMembers(canHoId: widget.canHoId);
      setState(() => _members = data);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _onSelectMember(Member member) async {
    setState(() => _loadingMemberId = member.quanHeCuTruId);
    try {
      final detail = await widget.service
          .getMemberDetail(quanHeCuTruId: member.quanHeCuTruId);
      if (mounted) Navigator.pop(context, (member, detail));
    } on AppException catch (e) {
      setState(() => _loadingMemberId = null);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chọn thành viên',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.red)))
                      : ListView.builder(
                          controller: controller,
                          itemCount: _members.length,
                          itemBuilder: (_, i) {
                            final m = _members[i];
                            final isLoading =
                                _loadingMemberId == m.quanHeCuTruId;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: m.anhDaiDienUrl != null
                                    ? NetworkImage(m.anhDaiDienUrl!)
                                    : null,
                                child: m.anhDaiDienUrl == null
                                    ? Text(m.fullName.isNotEmpty
                                        ? m.fullName[0]
                                        : '?')
                                    : null,
                              ),
                              title: Text(m.fullName),
                              subtitle: Text(m.loaiQuanHeTen),
                              trailing: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.chevron_right),
                              onTap: isLoading
                                  ? null
                                  : () => _onSelectMember(m),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}