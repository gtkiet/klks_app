// lib/features/home/models/home_data.dart

/// HomeData chứa thông tin hiển thị trên HomeScreen
class HomeData {
  final String fullName;
  final String? anhDaiDienUrl;

  const HomeData({required this.fullName, this.anhDaiDienUrl});

  /// Có thể mở rộng từ JSON nếu dùng API
  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      fullName: json['fullName'] ?? 'Người dùng',
      anhDaiDienUrl: json['anhDaiDienUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'fullName': fullName, 'anhDaiDienUrl': anhDaiDienUrl};
  }
}
