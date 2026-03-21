import 'package:flutter/material.dart';
import '../../../widgets/widgets.dart';
import '../services/residence_service.dart';

class ResidenceMemberScreen extends StatefulWidget {
  final int canHoId;
  final String canHoName;

  const ResidenceMemberScreen({
    super.key,
    required this.canHoId,
    required this.canHoName,
  });

  @override
  State<ResidenceMemberScreen> createState() => _ResidenceMemberScreenState();
}

class _ResidenceMemberScreenState extends State<ResidenceMemberScreen> {
  final ResidenceService _service = ResidenceService();

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _members = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _service.getMembersByCanHoId(widget.canHoId);

    if (result['success'] == true) {
      setState(() {
        _members = result['data'];
      });
    } else {
      final errors = result['errors'] as List?;
      setState(() {
        _errorMessage = errors != null && errors.isNotEmpty
            ? errors.map((e) => e['description']).join(', ')
            : 'Lỗi không xác định';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildMemberItem(Map<String, dynamic> member) {
    Color borderColor;
    switch (member['loaiQuanHeCuTruId'] ?? '') {
      case 1:
        borderColor = Colors.blue.shade400;
        break;
      case 2:
        borderColor = Colors.green.shade400;
        break;
      case 3:
        borderColor = Colors.orange.shade400;
        break;
      default:
        borderColor = Colors.grey.shade400;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: borderColor.withOpacity(0.2),
          child: CircleAvatar(
            radius: 25,
            backgroundImage:
                member['anhDaiDienUrl'] != null &&
                    member['anhDaiDienUrl'].toString().isNotEmpty
                ? NetworkImage(member['anhDaiDienUrl'])
                : null,
            child:
                (member['anhDaiDienUrl'] == null ||
                    member['anhDaiDienUrl'].toString().isEmpty)
                ? Icon(Icons.person, size: 28, color: borderColor)
                : null,
          ),
        ),
        title: Text(
          member['fullName'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  member['loaiQuanHeTen'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: borderColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Bắt đầu: ${member['ngayBatDau']?.split('T').first ?? ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF9CA3AF),
        ),
        onTap: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thành viên cư trú - ${widget.canHoName}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  SubmitButton(label: 'Thử lại', onPressed: _fetchMembers),
                ],
              ),
            )
          : _members.isEmpty
          ? const Center(child: Text('Không có thành viên cư trú'))
          : RefreshIndicator(
              onRefresh: _fetchMembers,
              child: ListView.builder(
                itemCount: _members.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (_, index) => _buildMemberItem(_members[index]),
              ),
            ),
    );
  }
}
