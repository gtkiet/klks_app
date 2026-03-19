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
    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return UserProfile(
      id: parseInt(json["id"]) ?? 0,
      username: json["username"]?.toString() ?? "",
      email: json["email"]?.toString() ?? "",
      firstName: json["firstName"]?.toString() ?? "",
      lastName: json["lastName"]?.toString() ?? "",
      phoneNumber: json["phoneNumber"]?.toString() ?? "",
      idCard: json["idCard"]?.toString() ?? "",
      diaChi: json["diaChi"]?.toString() ?? "",
      dob: parseDate(json["dob"]),
      gioiTinhId: parseInt(json["gioiTinhId"]),
      gioiTinhName: json["gioiTinhName"]?.toString() ?? "",
      roleId: parseInt(json["roleId"]),
      roleName: json["roleName"]?.toString() ?? "",
      anhDaiDienUrl: json["anhDaiDienUrl"]?.toString() ?? "",
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
      // gioiTinhName, roleName chỉ đọc, thường API update không cần
      "roleId": roleId,
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

  /// Trả về "First Last", trim và bỏ khoảng trắng thừa
  String get fullName {
    final parts = [firstName, lastName].map((e) => e.trim()).where((e) => e.isNotEmpty);
    return parts.join(" ");
  }

  /// Trả về "dd/MM/yyyy", trả "" nếu null
  String get formattedDob {
    if (dob == null) return "";
    return "${dob!.day.toString().padLeft(2, '0')}/${dob!.month.toString().padLeft(2, '0')}/${dob!.year}";
  }

  /// Tạo bản sao chỉ update avatar
  UserProfile copyWithAvatar(String url) => copyWith(anhDaiDienUrl: url);
}