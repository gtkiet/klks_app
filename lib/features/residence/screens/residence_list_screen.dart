import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/app_routes.dart';
import '../../../core/storage/user_session.dart';
import '../services/residence_service.dart';
import '../../../models/residence_model.dart';

class ResidenceListScreen extends StatefulWidget {
  const ResidenceListScreen({super.key});

  @override
  State<ResidenceListScreen> createState() => _ResidenceListScreenState();
}

class _ResidenceListScreenState extends State<ResidenceListScreen> {
  final ResidenceService _service = ResidenceService();

  bool _loading = true;
  String? _error;
  List<Residence> _residences = [];
  UserSession u = UserSession();

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

    final result = await _service.getMyResidences();

    if (result['success']) {
      final data = result['data'] as List;
      _residences = data.map((e) => Residence.fromJson(e)).toList();
    } else {
      _error = result['message'];
    }

    setState(() {
      _loading = false;
    });
  }

  Widget _buildCard(Residence r) {
    final isOwner = r.loaiQuanHeCuTruId == 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Apartment name + role badge
          Row(
            children: [
              Expanded(
                child: Text(
                  r.tenCanHo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isOwner
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOwner
                        ? const Color(0xFFBFDBFE)
                        : const Color(0xFFBBF7D0),
                  ),
                ),
                child: Text(
                  r.loaiQuanHeTen,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isOwner
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildInfoChip("Mã", r.maCanHo),
              _buildInfoChip("Tòa", "${r.tenToaNha} (${r.maToaNha})"),
              _buildInfoChip("Tầng", "${r.tenTang} (${r.maTang})"),
              _buildInfoChip("Cư dân", r.tongCuDan.toString()),
            ],
          ),
          const SizedBox(height: 12),

          // Start date
          Text(
            "Bắt đầu: ${DateFormat('dd/MM/yyyy').format(r.ngayBatDau)}",
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.residentDetail,
                      arguments: {'userId': u.userId, 'quanHeCuTruId': r.id},
                    );
                  },
                  icon: const Icon(Icons.person),
                  label: const Text("Chi tiết cư dân"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.residenceMembers,
                      arguments: {
                        'canHoId': r.canHoId,
                        'canHoName': r.tenCanHo,
                      },
                    );
                  },
                  icon: const Icon(Icons.group),
                  label: const Text("Thành viên cư trú"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LOADING
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Danh sách quan hệ cư trú")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // ERROR
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Danh sách quan hệ cư trú")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: const TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchData,
                child: const Text("Thử lại"),
              ),
            ],
          ),
        ),
      );
    }

    // EMPTY
    if (_residences.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Danh sách quan hệ cư trú")),
        body: const Center(
          child: Text(
            "Không có dữ liệu cư trú",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    // DATA
    return Scaffold(
      appBar: AppBar(title: const Text("Danh sách quan hệ cư trú")),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: _residences.length,
          itemBuilder: (context, index) {
            return _buildCard(_residences[index]);
          },
        ),
      ),
    );
  }
}
