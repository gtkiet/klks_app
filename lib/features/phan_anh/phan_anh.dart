// lib/features/phan_anh/phan_anh.dart
//
// Barrel export — import file này duy nhất ở nơi khác:
//   import 'package:your_app/features/phan_anh/phan_anh.dart';

export 'models/phan_anh_model.dart';
export 'services/phan_anh_service.dart';
export 'screens/phan_anh_list_screen.dart';
export 'screens/phan_anh_detail_screen.dart';
export 'screens/phan_anh_create_screen.dart';

// ---------------------------------------------------------------------------
// HOW TO WIRE INTO YOUR APP
// ---------------------------------------------------------------------------
//
// 1. pubspec.yaml — thêm dependency:
//      intl: ^0.19.0
//
// 2. Thêm route vào GoRouter hoặc MaterialApp:
//
//   // GoRouter example
//   GoRoute(
//     path: '/phan-anh',
//     builder: (_, __) => const PhanAnhListScreen(),
//     routes: [
//       GoRoute(
//         path: ':id',
//         builder: (_, state) => PhanAnhDetailScreen(
//           phanAnhId: int.parse(state.pathParameters['id']!),
//         ),
//       ),
//       GoRoute(
//         path: 'tao-moi',
//         builder: (_, __) => const PhanAnhCreateScreen(),
//       ),
//     ],
//   ),
//
//   // Navigator 1.0 example
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (_) => const PhanAnhListScreen()),
//   );
//
// 3. (Optional) Thêm menu item / bottom-nav tab dẫn đến PhanAnhListScreen.
// ---------------------------------------------------------------------------