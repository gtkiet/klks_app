/// HomeData chứa thông tin hiển thị trên HomeScreen
class HomeData {
  final String fullName;
  final String? avatarUrl;

  const HomeData({required this.fullName, this.avatarUrl});

  /// Có thể mở rộng từ JSON nếu dùng API
  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      fullName: json['fullName'] ?? 'Người dùng',
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'fullName': fullName, 'avatarUrl': avatarUrl};
  }
}
