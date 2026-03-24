// file: lib/features/profile/services/profile_service.dart

import 'dart:io';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/user_session.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_parser.dart';
import '../model/user_profile.dart';

/// ProfileService handles profile-related API calls:
/// - Get profile
/// - Update profile
/// - Change avatar
/// - Change password
/// 
/// Also syncs data into UserSession for app-wide access.
class ProfileService {
  final ApiClient _apiClient = ApiClient.instance;
  final UserSession _session = UserSession();

  /// ===================== GET PROFILE =====================
  Future<UserProfile?> getProfile() async {
    try {
      final response = await _apiClient.dio.post(
        "/api/profile/get-profile",
        data: {},
      );

      final data = response.data;

      if (data['isOk'] == true && data['result'] != null) {
        final profile = UserProfile.fromJson(data['result']);
        _syncSession(profile, data);
        return profile;
      }

      return null;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw AppException('Không thể lấy thông tin profile');
    }
  }

  /// ===================== CHANGE AVATAR =====================
  Future<String?> changeAvatar(File file) async {
    try {
      final response = await _apiClient.uploadFile(
        "/api/profile/change-avatar",
        fieldName: "avatar",
        filePath: file.path,
      );

      final data = response.data;

      if (data['isOk'] == true && data['result'] != null) {
        final newAvatarUrl = data['result'];
        _session.avatarUrl = newAvatarUrl;
        return newAvatarUrl;
      }

      throw AppException(
        data['errors']?[0]?['description'] ?? 'Upload avatar thất bại',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw AppException('Lỗi upload avatar');
    }
  }

  /// ===================== UPDATE PROFILE =====================
  Future<UserProfile> updateProfile({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String idCard,
    required DateTime dob,
    required int gioiTinhId,
    required String diaChi,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        "/api/profile",
        data: {
          "email": email,
          "firstName": firstName,
          "lastName": lastName,
          "phoneNumber": phoneNumber,
          "idCard": idCard,
          "dob": dob.toIso8601String(),
          "gioiTinhId": gioiTinhId,
          "diaChi": diaChi,
        },
      );

      final data = response.data;

      if (data['isOk'] == true && data['result'] != null) {
        final profile = UserProfile.fromJson(data['result']);
        _syncSession(profile, data);
        return profile;
      }

      throw AppException(
        data['errors']?[0]?['description'] ?? 'Cập nhật hồ sơ thất bại',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw AppException('Lỗi cập nhật hồ sơ');
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
        throw AppException('Mật khẩu mới không khớp');
      }

      final response = await _apiClient.dio.post(
        "/api/profile/change-password",
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        },
      );

      final data = response.data;

      if (data['isOk'] != true) {
        throw AppException(ErrorParser.parse(data));
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (_) {
      throw AppException('Lỗi đổi mật khẩu');
    }
  }

  /// ===================== HELPER: SYNC SESSION =====================
  void _syncSession(UserProfile profile, Map<String, dynamic> data) {
    _session.userId = profile.id;
    _session.username = profile.username;
    _session.email = profile.email;
    _session.fullName = profile.fullName;
    _session.role = profile.roleName;
    _session.avatarUrl = profile.anhDaiDienUrl;

    if (data['accessToken'] != null) _session.accessToken = data['accessToken'];
    if (data['refreshToken'] != null) _session.refreshToken = data['refreshToken'];
  }

  /// ===================== HELPER: DIO ERROR =====================
  AppException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return AppException('Kết nối quá chậm, vui lòng thử lại');
    }

    if (e.response != null) {
      final statusCode = e.response?.statusCode;

      if (statusCode == 401) {
        return AppException('Phiên đăng nhập đã hết hạn', code: 401);
      }

      return AppException(
        ErrorParser.parse(e.response?.data),
        code: statusCode,
      );
    }

    return AppException('Không thể kết nối đến server');
  }
}