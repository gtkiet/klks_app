// lib/features/profile/model/user_profile.dart

class UserProfile {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? phoneNumber;
  final String? idCard;
  final DateTime? dob;
  final int? gioiTinhId;
  final String? diaChi;
  final String? roleName;
  final String? anhDaiDienUrl;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.phoneNumber,
    this.idCard,
    this.dob,
    this.gioiTinhId,
    this.diaChi,
    this.roleName,
    this.anhDaiDienUrl,
  });

  /// Tạo từ JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      fullName: json['fullName'] ?? '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      phoneNumber: json['phoneNumber'],
      idCard: json['idCard'],
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      gioiTinhId: json['gioiTinhId'],
      diaChi: json['diaChi'],
      roleName: json['roleName'],
      anhDaiDienUrl: json['anhDaiDienUrl'],
    );
  }

  /// Chuyển sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'idCard': idCard,
      'dob': dob?.toIso8601String(),
      'gioiTinhId': gioiTinhId,
      'diaChi': diaChi,
      'roleName': roleName,
      'anhDaiDienUrl': anhDaiDienUrl,
    };
  }

  /// Tạo bản sao với một số field có thể thay đổi
  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phoneNumber,
    String? idCard,
    DateTime? dob,
    int? gioiTinhId,
    String? diaChi,
    String? roleName,
    String? anhDaiDienUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idCard: idCard ?? this.idCard,
      dob: dob ?? this.dob,
      gioiTinhId: gioiTinhId ?? this.gioiTinhId,
      diaChi: diaChi ?? this.diaChi,
      roleName: roleName ?? this.roleName,
      anhDaiDienUrl: anhDaiDienUrl ?? this.anhDaiDienUrl,
    );
  }
}