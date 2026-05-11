// lib/features/profile/services/profile_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/user_session.dart';
import '../../auth/services/auth_service.dart';
import '../models/user_profile.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  static final _client = ApiClient.instance;

  // ── Remote profile ────────────────────────────────────────────────────────

  Future<UserProfile> getProfile() async {
    final res = await _client.post('/api/profile/get-profile');
    return res.item(UserProfile.fromJson);
  }

  // ── Change avatar ─────────────────────────────────────────────────────────
  //
  // Sau khi upload thành công, gọi updateAvatar() → HomeScreen tự rebuild.

  Future<String> changeAvatar(File file) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final res = await _client.postForm('/api/profile/change-avatar', formData);
    final url = res.raw<String>();
    await UserSession.instance.updateAvatar(url);
    return url;
  }

  // ── Change password ───────────────────────────────────────────────────────
  //
  // Validate client-side trước khi gọi API để tránh request thừa.

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      throw const AppException('Mật khẩu xác nhận không khớp');
    }
    if (oldPassword == newPassword) {
      throw const AppException('Mật khẩu mới không được trùng mật khẩu cũ');
    }

    await _client.post(
      '/api/profile/change-password',
      body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() => AuthService.instance.logout();
}
