import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../../models/user_profile.dart';

class ProfileService {
  // ================= GET PROFILE =================
  static Future<UserProfile> getProfile() async {
    final data = await ApiClient.post(
      "/api/profile/get-profile",
      body: {},
    );

    if (data["isOk"] == true && data["result"] != null) {
      return UserProfile.fromJson(data["result"]);
    }

    throw Exception(
      data["errors"]?[0]?["description"] ?? "Lấy hồ sơ thất bại",
    );
  }

  // ================= CHANGE AVATAR =================
  static Future<String> changeAvatar(File file) async {
    final data = await ApiClient.uploadFile(
      "/api/profile/change-avatar",
      fieldName: "avatar",
      filePath: file.path,
    );

    if (data["isOk"] == true && data["result"] != null) {
      return data["result"];
    }

    throw Exception(
      data["errors"]?[0]?["description"] ?? "Upload avatar failed",
    );
  }

  // ================= UPDATE PROFILE =================
  static Future<UserProfile> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String idCard,
    required DateTime dob,
    required int gioiTinhId,
    required String diaChi,
  }) async {
    final data = await ApiClient.put(
      "/api/profile",
      body: {
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "idCard": idCard,
        "dob": dob.toIso8601String(),
        "gioiTinhId": gioiTinhId,
        "diaChi": diaChi,
      },
    );

    if (data["isOk"] == true && data["result"] != null) {
      return UserProfile.fromJson(data["result"]);
    }

    throw Exception(
      data["errors"]?[0]?["description"] ?? "Cập nhật hồ sơ thất bại",
    );
  }
}