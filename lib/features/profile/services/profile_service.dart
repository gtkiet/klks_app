// lib/features/profile/services/profile_service.dart

import 'dart:io';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/user_session.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_parser.dart';
import '../model/user_profile.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient.instance;
  final UserSession _session = UserSession();

  /// ===================== GET SESSION PROFILE =====================
  Future<Map<String, String?>> getSessionProfile() async {
    return {
      'fullName': await _session.getFullName(),
      'email': await _session.getEmail(),
      'role': await _session.getRole(),
      'anhDaiDienUrl': await _session.getanhDaiDienUrl(),
    };
  }

  /// ===================== GET PROFILE =====================
  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiClient.dio.post("/api/profile/get-profile");

      final data = response.data;
      final profile = UserProfile.fromJson(data['result']);
      return profile;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  /// ===================== CHANGE AVATAR =====================
  Future<String> changeAvatar(File file) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await _apiClient.dio.post(
        "/api/profile/change-avatar",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;

      final url = data['result'].toString();
      _session.updateAvatar(url);
      return url;
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }

  /// ===================== CHANGE PASSWORD =====================
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        throw AppException('Mật khẩu xác nhận không khớp');
      }

      if (oldPassword == newPassword) {
        throw AppException('Mật khẩu mới không được trùng mật khẩu cũ');
      }

      await _apiClient.dio.post(
        "/api/profile/change-password",
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw ErrorParser.parse(
        e.response?.data,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      throw AppException('Lỗi không xác định');
    }
  }
}
