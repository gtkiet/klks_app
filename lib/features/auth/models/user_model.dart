// lib/features/auth/models/user_model.dart
class UserModel {
  final int userId;
  final int accountId;
  final String username;
  final String email;
  final String anhDaiDienUrl;
  final String role;
  final String fullName;
  final String accessToken;
  final String refreshToken;

  UserModel({
    required this.userId,
    required this.accountId,
    required this.username,
    required this.email,
    required this.anhDaiDienUrl,
    required this.role,
    required this.fullName,
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      accountId: json['accountId'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      anhDaiDienUrl: json['anhDaiDienUrl'] ?? '',
      role: json['role'] ?? '',
      fullName: json['fullName'] ?? '',
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'accountId': accountId,
      'username': username,
      'email': email,
      'anhDaiDienUrl': anhDaiDienUrl,
      'role': role,
      'fullName': fullName,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  UserModel copyWith({
    int? userId,
    int? accountId,
    String? username,
    String? email,
    String? anhDaiDienUrl,
    String? role,
    String? fullName,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      email: email ?? this.email,
      anhDaiDienUrl: anhDaiDienUrl ?? this.anhDaiDienUrl,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
