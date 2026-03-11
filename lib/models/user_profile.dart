class UserProfile {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String idCard;
  final String diaChi;
  final String dob;
  final int gioiTinhId;
  final String gioiTinhName;
  final int roleId;
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
    required this.dob,
    required this.gioiTinhId,
    required this.gioiTinhName,
    required this.roleId,
    required this.roleName,
    required this.anhDaiDienUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"],
      username: json["username"],
      email: json["email"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      phoneNumber: json["phoneNumber"],
      idCard: json["idCard"],
      diaChi: json["diaChi"],
      dob: json["dob"],
      gioiTinhId: json["gioiTinhId"],
      gioiTinhName: json["gioiTinhName"],
      roleId: json["roleId"],
      roleName: json["roleName"],
      anhDaiDienUrl: json["anhDaiDienUrl"],
    );
  }
}