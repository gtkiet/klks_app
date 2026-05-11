// lib/shared/models/shared_models.dart
//
// Barrel duy nhất cho toàn bộ shared models.
//
// CÁCH DÙNG:
//   Trong model của feature — re-export những gì feature đó cần:
//     export 'package:your_app/shared/models/paging_model.dart';
//     export 'package:your_app/shared/models/file_model.dart';
//
//   KHÔNG import barrel này trực tiếp trong service —
//   luôn đi qua model của feature để giữ dependency rõ ràng.

export 'paging_model.dart';
export 'file_model.dart';
export 'selector_item_model.dart';
