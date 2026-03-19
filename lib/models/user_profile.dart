class UserProfile {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String idCard;
  final String diaChi;
  final DateTime? dob;
  final int? gioiTinhId;
  final String gioiTinhName;
  final int? roleId;
  final String roleName;
  final String anhDaiDienUrl;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.idCard,
    required this.diaChi,
    this.dob,
    this.gioiTinhId,
    required this.gioiTinhName,
    this.roleId,
    required this.roleName,
    required this.anhDaiDienUrl,
  });

  /// =========================
  /// 🔥 FROM JSON (SAFE)
  /// =========================
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"] ?? 0,
      username: json["username"] ?? "",
      email: json["email"] ?? "",
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      idCard: json["idCard"] ?? "",
      diaChi: json["diaChi"] ?? "",
      dob: json["dob"] != null ? DateTime.tryParse(json["dob"]) : null,
      gioiTinhId: json["gioiTinhId"],
      gioiTinhName: json["gioiTinhName"] ?? "",
      roleId: json["roleId"],
      roleName: json["roleName"] ?? "",
      anhDaiDienUrl: json["anhDaiDienUrl"] ?? "",
    );
  }

  /// =========================
  /// 🔥 TO JSON
  /// =========================
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "firstName": firstName,
      "lastName": lastName,
      "phoneNumber": phoneNumber,
      "idCard": idCard,
      "diaChi": diaChi,
      "dob": dob?.toIso8601String(),
      "gioiTinhId": gioiTinhId,
      "gioiTinhName": gioiTinhName,
      "roleId": roleId,
      "roleName": roleName,
      "anhDaiDienUrl": anhDaiDienUrl,
    };
  }

  /// =========================
  /// 🔥 COPY WITH (FULL)
  /// =========================
  UserProfile copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? idCard,
    String? diaChi,
    DateTime? dob,
    int? gioiTinhId,
    String? gioiTinhName,
    int? roleId,
    String? roleName,
    String? anhDaiDienUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idCard: idCard ?? this.idCard,
      diaChi: diaChi ?? this.diaChi,
      dob: dob ?? this.dob,
      gioiTinhId: gioiTinhId ?? this.gioiTinhId,
      gioiTinhName: gioiTinhName ?? this.gioiTinhName,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      anhDaiDienUrl: anhDaiDienUrl ?? this.anhDaiDienUrl,
    );
  }

  /// =========================
  /// 🔥 HELPER
  /// =========================
  String get fullName => "$lastName $firstName";

  String get formattedDob {
    if (dob == null) return "";
    return "${dob!.day}/${dob!.month}/${dob!.year}";
  }
}