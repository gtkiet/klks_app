// lib/features/residence/screens/apartment_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/residence_apartment.dart';
import '../widgets/member_tab.dart';
import '../widgets/request_tab.dart';

class ApartmentDetailScreen extends StatefulWidget {
  final int canHoId;
  final ResidenceApartment apartment;

  const ApartmentDetailScreen({
    super.key,
    required this.canHoId,
    required this.apartment,
  });

  @override
  State<ApartmentDetailScreen> createState() => _ApartmentDetailScreenState();
}

class _ApartmentDetailScreenState extends State<ApartmentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCreateRequest() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => CreateRequestScreen(apartment: widget.apartment),
    //   ),
    // );
    context.push(
      '/residence/apartment/${widget.canHoId}/create-request',
      extra: widget.apartment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.apartment.tenCanHo),
        // subtitle: Text(
        //   '${widget.apartment.tenToaNha} · Tầng ${widget.apartment.tenTang}',
        // ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Thành viên'),
            Tab(text: 'Yêu cầu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MemberTab(canHoId: widget.canHoId),
          RequestTab(canHoId: widget.canHoId),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onCreateRequest,
        icon: const Icon(Icons.add),
        label: const Text('Tạo yêu cầu'),
      ),
    );
  }
}