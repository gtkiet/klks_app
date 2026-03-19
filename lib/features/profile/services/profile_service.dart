import 'dart:io';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../models/user_profile.dart';

class ProfileService {
  // ================= GET PROFILE =================
  Future<ApiResponse<UserProfile>> getProfile() async {
    try {
      final res = await ApiClient.post<Map<String, dynamic>>(
        "/api/profile/get-profile",
        body: {},
      );

      if (res.isOk && res.data?["result"] != null) {
        return ApiResponse.success(
          UserProfile.fromJson(res.data!["result"]),
        );
      }

      return ApiResponse.failure(
        message: res.data?["errors"]?[0]?["description"] ?? "Lấy hồ sơ thất bại",
      );
    } catch (e) {
      return ApiResponse.failure(message: "Lấy hồ sơ thất bại: $e");
    }
  }

  // ================= CHANGE AVATAR =================
  Future<ApiResponse<String>> changeAvatar(File file) async {
    try {
      final res = await ApiClient.uploadFile<Map<String, dynamic>>(
        "/api/profile/change-avatar",
        fieldName: "avatar",
        filePath: file.path,
      );

      if (res.isOk && res.data?["result"] != null) {
        return ApiResponse.success(res.data!["result"] as String);
      }

      return ApiResponse.failure(
        message: res.data?["errors"]?[0]?["description"] ?? "Upload avatar thất bại",
      );
    } catch (e) {
      return ApiResponse.failure(message: "Upload avatar thất bại: $e");
    }
  }

  // ================= UPDATE PROFILE =================
  Future<ApiResponse<UserProfile>> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String idCard,
    required DateTime dob,
    required int gioiTinhId,
    required String diaChi,
  }) async {
    try {
      final res = await ApiClient.put<Map<String, dynamic>>(
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

      if (res.isOk && res.data?["result"] != null) {
        return ApiResponse.success(
          UserProfile.fromJson(res.data!["result"]),
        );
      }

      return ApiResponse.failure(
        message: res.data?["errors"]?[0]?["description"] ?? "Cập nhật hồ sơ thất bại",
      );
    } catch (e) {
      return ApiResponse.failure(message: "Cập nhật hồ sơ thất bại: $e");
    }
  }
}