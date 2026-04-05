// lib/features/residence/screens/apartment_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/residence_apartment.dart';
import '../services/residence_service.dart';
import '../../../../core/errors/app_exception.dart';

class ApartmentListScreen extends StatefulWidget {
  const ApartmentListScreen({super.key});

  @override
  State<ApartmentListScreen> createState() => _ApartmentListScreenState();
}

class _ApartmentListScreenState extends State<ApartmentListScreen> {
  final _service = ResidenceService.instance;

  bool _loading = true;
  String? _error;
  List<ResidenceApartment> _apartments = [];

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
      final data = await _service.getMyApartments();
      setState(() => _apartments = data);
    } on AppException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Căn hộ của tôi')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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

    if (_apartments.isEmpty) {
      return const Center(child: Text('Không có căn hộ nào'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _apartments.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final apt = _apartments[index];
          return _ApartmentCard(
            apartment: apt,
            // onTap: () => Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => ApartmentDetailScreen(
            //       canHoId: apt.canHoId,
            //       apartment: apt,
            //     ),
            //   ),
            // ),
            onTap: () =>
                context.push('/residence/apartment/${apt.canHoId}', extra: apt),
          );
        },
      ),
    );
  }
}

class _ApartmentCard extends StatelessWidget {
  final ResidenceApartment apartment;
  final VoidCallback onTap;

  const _ApartmentCard({required this.apartment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            apartment.maCanHo.isNotEmpty
                ? apartment.maCanHo[0].toUpperCase()
                : '?',
            style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(apartment.tenCanHo, style: theme.textTheme.titleMedium),
        subtitle: Text('${apartment.tenToaNha} · Tầng ${apartment.tenTang}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${apartment.tongCuDan} cư dân',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                apartment.loaiQuanHeTen,
                style: const TextStyle(fontSize: 11),
              ),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
