// lib/features/residence/widgets/member_tab.dart

import 'package:flutter/material.dart';
// import '../models/residence_models.dart';
import '../services/residence_service.dart';
import '../../../core/errors/app_exception.dart';

import '../models/member.dart';

class MemberTab extends StatefulWidget {
  final int canHoId;

  const MemberTab({super.key, required this.canHoId});

  @override
  State<MemberTab> createState() => _MemberTabState();
}

class _MemberTabState extends State<MemberTab>
    with AutomaticKeepAliveClientMixin {
  final _service = ResidenceService.instance;

  bool _loading = true;
  String? _error;
  List<Member> _members = [];

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
      final data = await _service.getMembers(canHoId: widget.canHoId);
      setState(() => _members = data);
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

    if (_members.isEmpty) {
      return const Center(child: Text('Chưa có thành viên nào'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _members.length,
        itemBuilder: (_, i) => _MemberTile(member: _members[i]),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Member member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: member.anhDaiDienUrl != null
            ? NetworkImage(member.anhDaiDienUrl!)
            : null,
        child: member.anhDaiDienUrl == null
            ? Text(member.fullName.isNotEmpty ? member.fullName[0] : '?')
            : null,
      ),
      title: Text(member.fullName),
      subtitle: Text(member.loaiQuanHeTen),
      trailing: Text(
        '${member.ngayBatDau.day}/${member.ngayBatDau.month}/${member.ngayBatDau.year}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}