// lib/features/profile/models/user_profile.dart

class UserProfile {
  final String id;
  final String username;
  final String email;

  final String firstName;
  final String lastName;

  final String? phoneNumber;
  final String? diaChi;

  final DateTime? dob;
  final int? gioiTinhId;
  final String? gioiTinhName;

  final List<String> roles;

  final String? anhDaiDienUrl;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    this.phoneNumber,
    this.diaChi,
    this.dob,
    this.gioiTinhId,
    this.gioiTinhName,
    this.anhDaiDienUrl,
  });

  /// ===================== FROM JSON =====================
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      phoneNumber: json['phoneNumber'],
      diaChi: json['diaChi'],
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      gioiTinhId: json['gioiTinhId'],
      gioiTinhName: json['gioiTinhName'],
      roles: (json['roles'] as List?)?.map((e) => e.toString()).toList() ?? [],
      anhDaiDienUrl: json['anhDaiDienUrl'],
    );
  }

  /// ===================== TO JSON =====================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'diaChi': diaChi,
      'dob': dob?.toIso8601String(),
      'gioiTinhId': gioiTinhId,
      'gioiTinhName': gioiTinhName,
      'roles': roles,
      'anhDaiDienUrl': anhDaiDienUrl,
    };
  }

  /// ===================== COPY WITH =====================
  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? diaChi,
    DateTime? dob,
    int? gioiTinhId,
    String? gioiTinhName,
    List<String>? roles,
    String? anhDaiDienUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      diaChi: diaChi ?? this.diaChi,
      dob: dob ?? this.dob,
      gioiTinhId: gioiTinhId ?? this.gioiTinhId,
      gioiTinhName: gioiTinhName ?? this.gioiTinhName,
      roles: roles ?? this.roles,
      anhDaiDienUrl: anhDaiDienUrl ?? this.anhDaiDienUrl,
    );
  }
}
