// // lib/features/dich_vu_dang_ky/screens/dich_vu_dang_ky_list_screen.dart

// import 'package:flutter/material.dart';

// import '../../dich_vu/models/selector_item.dart';
// import '../models/dich_vu_dang_ky_model.dart';
// import '../models/dich_vu_dang_ky_request.dart';
// import '../services/dich_vu_dang_ky_service.dart';
// import 'dich_vu_dang_ky_filter_screen.dart';

// class DichVuDangKyListScreen extends StatefulWidget {
//   const DichVuDangKyListScreen({super.key});

//   @override
//   State<DichVuDangKyListScreen> createState() => _DichVuDangKyListScreenState();
// }

// class _DichVuDangKyListScreenState extends State<DichVuDangKyListScreen> {
//   final _service = DichVuDangKyService.instance;

//   List<DichVuDangKyItem> _items = [];
//   PagingInfo? _paging;
//   bool _isLoading = false;
//   String? _error;

//   // Catalog
//   List<SelectorItem> _loaiDichVuList = [];

//   // Filter state — mặc định tiện ích
//   DichVuDangKyRequest _request = DichVuDangKyRequest.tienIch();

//   @override
//   void initState() {
//     super.initState();
//     _loadCatalogs();
//     _loadData();
//   }

//   // ── Catalog ───────────────────────────────────────────────────────────────

//   Future<void> _loadCatalogs() async {
//     try {
//       final list = await _service.getLoaiDichVu();
//       if (!mounted) return;
//       setState(() => _loaiDichVuList = list);
//     } catch (_) {
//       // Catalog lỗi không block UI chính
//     }
//   }

//   // ── Data ──────────────────────────────────────────────────────────────────

//   Future<void> _loadData({bool reset = false}) async {
//     if (reset) {
//       _request = _request.copyWith(pageNumber: 1);
//       _items = [];
//     }

//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final result = await _service.getDanhSachDangKy(_request);
//       setState(() {
//         _items = reset ? result.items : [..._items, ...result.items];
//         _paging = result.pagingInfo;
//       });
//     } catch (e) {
//       setState(() => _error = e.toString());
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _onLoadMore() {
//     if (_paging != null && _paging!.hasNextPage && !_isLoading) {
//       _request = _request.copyWith(pageNumber: _request.pageNumber + 1);
//       _loadData();
//     }
//   }

//   void _openFilter() async {
//     final newRequest = await Navigator.push<DichVuDangKyRequest>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => DichVuDangKyFilterScreen(
//           currentRequest: _request,
//           loaiDichVuList: _loaiDichVuList,
//         ),
//       ),
//     );
//     if (newRequest != null) {
//       _request = newRequest;
//       _loadData(reset: true);
//     }
//   }

//   // ── Build ─────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dịch Vụ Đã Đăng Ký'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.filter_list),
//             tooltip: 'Bộ lọc',
//             onPressed: _openFilter,
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => _loadData(reset: true),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Paging banner
//           if (_paging != null)
//             Container(
//               width: double.infinity,
//               color: Colors.blue.shade50,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//               child: Text(
//                 'Tổng: ${_paging!.totalItems} dịch vụ  •  Trang ${_paging!.pageNumber}',
//                 style: const TextStyle(fontSize: 13, color: Colors.blue),
//               ),
//             ),
//           Expanded(child: _buildBody()),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading && _items.isEmpty) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_error != null && _items.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.error_outline, size: 48, color: Colors.red),
//               const SizedBox(height: 12),
//               Text(_error!, textAlign: TextAlign.center),
//               const SizedBox(height: 16),
//               ElevatedButton.icon(
//                 onPressed: () => _loadData(reset: true),
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Thử lại'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_items.isEmpty) {
//       return const Center(
//         child: Text(
//           'Không có dịch vụ nào.',
//           style: TextStyle(fontSize: 16, color: Colors.grey),
//         ),
//       );
//     }

//     return NotificationListener<ScrollNotification>(
//       onNotification: (n) {
//         if (n is ScrollEndNotification &&
//             n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
//           _onLoadMore();
//         }
//         return false;
//       },
//       child: RefreshIndicator(
//         onRefresh: () => _loadData(reset: true),
//         child: ListView.separated(
//           padding: const EdgeInsets.all(12),
//           itemCount: _items.length + (_paging?.hasNextPage == true ? 1 : 0),
//           separatorBuilder: (_, _) => const SizedBox(height: 8),
//           itemBuilder: (_, index) {
//             if (index == _items.length) {
//               return const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(16),
//                   child: CircularProgressIndicator(),
//                 ),
//               );
//             }
//             return _DichVuDangKyCard(item: _items[index]);
//           },
//         ),
//       ),
//     );
//   }
// }

// // ── Card ──────────────────────────────────────────────────────────────────────

// class _DichVuDangKyCard extends StatelessWidget {
//   const _DichVuDangKyCard({required this.item});

//   final DichVuDangKyItem item;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     item.tenDichVu,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 _TrangThaiChip(
//                   label: item.trangThaiDangKyTen,
//                   isActive: item.isActive,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text(
//               '${item.maDichVu}  •  ${item.loaiDichVuTen}',
//               style: const TextStyle(fontSize: 13, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.shopping_bag_outlined,
//                     size: 15, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Text('Số lượng: ${item.soLuong}',
//                     style: const TextStyle(fontSize: 13)),
//                 const SizedBox(width: 16),
//                 const Icon(Icons.date_range_outlined,
//                     size: 15, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Expanded(
//                   child: Text(
//                     item.thoiGianHienThi,
//                     style: const TextStyle(fontSize: 13),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _TrangThaiChip extends StatelessWidget {
//   const _TrangThaiChip({required this.label, required this.isActive});

//   final String label;
//   final bool isActive;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: isActive ? Colors.green.shade100 : Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label.isNotEmpty ? label : 'N/A',
//         style: TextStyle(
//           fontSize: 12,
//           color: isActive ? Colors.green.shade800 : Colors.grey.shade700,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }