import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_client.dart';
import '../../../models/user_profile.dart';

class ProfileService {
  static const storage = FlutterSecureStorage();

  // ================= GET PROFILE =================
  static Future<UserProfile?> getProfile() async {
    try {
      final data = await ApiClient.post(
        "/api/profile/get-profile",
        body: {},
      );

      if (data["isOk"] == true && data["result"] != null) {
        return UserProfile.fromJson(data["result"]);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // ================= CHANGE AVATAR =================
  static Future<String?> changeAvatar(File file) async {
    try {
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
    } catch (e) {
      throw Exception("Lỗi upload avatar");
    }
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
    try {
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
    } catch (e) {
      throw Exception("Lỗi cập nhật hồ sơ");
    }
  }
}