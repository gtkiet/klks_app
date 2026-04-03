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

  /// ===================== GET PROFILE =====================
  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiClient.dio.post("/api/profile/get-profile");

      final data = response.data;

      if (data['isOk'] == true && data['result'] != null) {
        final profile = UserProfile.fromJson(data['result']);
        // _syncSession(profile);
        return profile;
      }

      throw AppException(ErrorParser.parse(data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Không thể lấy thông tin profile: ${e.toString()}');
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

      if (data['isOk'] == true && data['result'] != null) {
        final url = data['result'].toString();
        _session.updateAvatar(url);
        // _session.anhDaiDienUrl = url;
        return url;
      }

      throw AppException(ErrorParser.parse(data));
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Lỗi upload avatar: ${e.toString()}');
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
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Lỗi đổi mật khẩu: ${e.toString()}');
    }
  }

  /// ===================== SESSION SYNC =====================
  // void _syncSession(UserProfile profile) {
  //   _session.userId = profile.id;
  //   _session.username = profile.username;
  //   _session.email = profile.email;
  //   _session.fullName = profile.fullName;
  //   _session.role = profile.roles.isNotEmpty ? profile.roles.first : null;
  //   _session.anhDaiDienUrl = profile.anhDaiDienUrl;
  // }

  /// ===================== ERROR HANDLER =====================
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
