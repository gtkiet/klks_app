// File: lib/widgets/widgets.dart

/// ────────────── WIDGETS TỔNG HỢP 7 NHÓM ──────────────

/// Nhóm 1: Buttons
export 'buttons/buttons.dart';
/*
| Button type       | Mục đích sử dụng             |
| ----------------- | ---------------------------- |
| PrimaryButton     | Submit, xác nhận thao tác    |
| SecondaryButton   | Hủy thao tác, back           |
| SuccessButton     | Chỉnh sửa, confirm success   |
| DangerButton      | Xóa, hủy quan trọng          |
| GhostButton       | Button nhẹ, ít nổi bật       |
| IconTextButton    | Icon + label, toolbar/action |
| FABCustom         | Floating action button tròn  |
*/

/// Nhóm 2: Form / Input
export 'form_fields/form_fields.dart';
/*
| Widget               | Mục đích                    |
| -------------------- | --------------------------- |
| LabelText            | Nhãn section / field        |
| CustomTextField      | Text input chuẩn, validator |
| PasswordField        | Nhập mật khẩu, show/hide    |
| DateField            | Chọn ngày                   |
| DropdownField<T>     | Chọn từ list                |
| SearchField          | Input tìm kiếm với icon     |
| NumberField          | Input chỉ số, digitsOnly    |
| SwitchField          | Toggle ON/OFF               |
| MultiLineTextField   | Nhập văn bản dài            |
*/

/// Nhóm 3: Profile / Info
export 'profile/profile_widgets.dart';
/*
| Widget                 | Mục đích                                             |
| ---------------------- | ---------------------------------------------------- |
| AvatarWidget           | Hiển thị avatar người dùng, có option border + onTap |
| EditProfileButton      | Nút chỉnh sửa hồ sơ                                  |
| ChangePasswordButton   | Nút đổi mật khẩu                                     |
| LogoutButton           | Nút đăng xuất, style danger                          |
| SectionLabel           | Label phân vùng info                                 |
| InfoCard               | Card tổng hợp các InfoRow                            |
| InfoRowWidget          | Row hiển thị từng thông tin với icon + label + value |
*/

/// Nhóm 4: List / Item
export 'list_widgets/list_widgets.dart';
/*
| Widget               | Mục đích                                                           |
| -------------------- | ------------------------------------------------------------------ |
| ListItem             | Model cho 1 item, chứa title, subtitle, image, icon, status, onTap |
| ListItemCard         | Card item dạng row với image/icon + text + status                  |
| SimpleListTile       | Dạng ListTile đơn giản với icon, title, subtitle và trailing arrow |
| StarRating           | Hiển thị đánh giá sao                                               |
| ListItemActionCard   | Card item với 1-2 action button                                     |
| ListItemTagCard      | Card item kèm tags / badges                                         |
| HorizontalCard       | Card dạng cuộn ngang (scroll)                                       |
*/

/// Nhóm 5: Detail / Card
export 'detail_widgets/detail_widgets.dart';
/*
| Widget                 | Mục đích                                                   |
| ---------------------- | ---------------------------------------------------------- |
| DetailRow              | Model cho 1 dòng thông tin chi tiết                        |
| DetailCard             | Card hiển thị nhiều dòng chi tiết, có optional edit button |
| HorizontalDetailCard   | Card dạng ngang, có thể kèm hình ảnh                       |
| TagsDetailCard         | Card chi tiết hiển thị tags / badges                       |
*/

/// Nhóm 6: Status / Progress / Timeline
export 'status_widgets/status_widgets.dart';
/*
| Widget         | Mục đích                                                             |
| -------------- | -------------------------------------------------------------------- |
| ProgressCard   | Card hiển thị tiến độ với thanh progress và optional text            |
| StatusBadge    | Badge trạng thái nhỏ, màu sắc tùy biến                               |
| TimelineItem   | Model cho 1 bước timeline                                            |
| TimelineCard   | Card hiển thị danh sách timeline items dạng cột với vòng tròn & line |
*/

/// Nhóm 7: Placeholder / Notification
export 'placeholder_widgets/placeholder_widgets.dart';
/*
| Widget             | Mục đích                                        |
| ------------------ | ----------------------------------------------- |
| EmptyState         | Hiển thị khi danh sách rỗng, có optional button |
| LoadingState       | Hiển thị loading với progress indicator         |
| NotificationCard   | Card thông báo / alert đơn giản                 |
| BadgeIcon          | Hiển thị số lượng thông báo / badge             |
*/