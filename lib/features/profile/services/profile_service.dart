import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/user_session.dart';
import '../../../models/user_profile.dart';

class ProfileService {
  static const storage = FlutterSecureStorage();

  // ================= GET PROFILE =================
  static Future<UserProfile?> getProfile() async {
    try {
      final data = await ApiClient.post("/api/profile/get-profile", body: {});

      if (data["isOk"] == true && data["result"] != null) {
        final profile = UserProfile.fromJson(data["result"]);

        // 🔥 Sync full session
        _syncSession(profile, data);

        return profile;
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
        final newAvatarUrl = data["result"];

        // 🔥 Update session avatar ngay
        final session = UserSession();
        session.avatarUrl = newAvatarUrl;

        return newAvatarUrl;
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
        final profile = UserProfile.fromJson(data["result"]);

        // 🔥 Sync full session
        _syncSession(profile, data);

        return profile;
      }

      throw Exception(
        data["errors"]?[0]?["description"] ?? "Cập nhật hồ sơ thất bại",
      );
    } catch (e) {
      throw Exception("Lỗi cập nhật hồ sơ");
    }
  }

  // ================= HELPER: SYNC SESSION =================
  static void _syncSession(UserProfile profile, Map<String, dynamic> data) {
    final session = UserSession();

    session.userId = profile.id;
    session.username = profile.username;
    session.email = profile.email;
    session.fullName = profile.fullName;
    session.role = profile.roleName;
    session.avatarUrl = profile.anhDaiDienUrl;

    // Cập nhật token nếu API trả về (ví dụ khi login hoặc refresh)
    if (data.containsKey('accessToken') && data['accessToken'] != null) {
      session.accessToken = data['accessToken'];
    }
    if (data.containsKey('refreshToken') && data['refreshToken'] != null) {
      session.refreshToken = data['refreshToken'];
    }
  }

  /// ================= CHANGE PASSWORD =================
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      return await ApiClient.post(
        "/api/profile/change-password",
        body: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        },
      );
    } catch (_) {
      return _error("Lỗi kết nối");
    }
  }

  /// ================= HELPER =================
  Map<String, dynamic> _error(String message) {
    return {
      "isOk": false,
      "errors": [
        {"description": message},
      ],
    };
  }
}
