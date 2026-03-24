// lib/core/storage/user_session.dart

import 'secure_storage.dart';
import '../constants/storage_keys.dart';

class _SessionKeys {
  static const accessToken = StorageKeys.accessToken;
  static const refreshToken = StorageKeys.refreshToken;

  // Profile keys
  static const userId = 'userId';
  static const username = 'username';
  static const email = 'email';
  static const fullName = 'fullName';
  static const role = 'role';
  static const avatarUrl = 'avatarUrl';
}

/// UserSession handles both tokens and basic profile info.
/// Only stores/retrieves from secure storage, no API logic.
class UserSession {
  UserSession._internal();
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;

  final SecureStorage _storage = SecureStorage();

  // Token
  String? accessToken;
  String? refreshToken;

  // Profile info
  String? userId;
  String? username;
  String? email;
  String? fullName;
  String? role;
  String? avatarUrl;

  /// Save tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    await Future.wait([
      _storage.write(key: _SessionKeys.accessToken, value: accessToken),
      _storage.write(key: _SessionKeys.refreshToken, value: refreshToken),
    ]);
  }

  /// Save profile info
  Future<void> saveProfile({
    required String userId,
    required String username,
    required String email,
    required String fullName,
    required String role,
    required String avatarUrl,
  }) async {
    this.userId = userId;
    this.username = username;
    this.email = email;
    this.fullName = fullName;
    this.role = role;
    this.avatarUrl = avatarUrl;

    await Future.wait([
      _storage.write(key: _SessionKeys.userId, value: userId),
      _storage.write(key: _SessionKeys.username, value: username),
      _storage.write(key: _SessionKeys.email, value: email),
      _storage.write(key: _SessionKeys.fullName, value: fullName),
      _storage.write(key: _SessionKeys.role, value: role),
      _storage.write(key: _SessionKeys.avatarUrl, value: avatarUrl),
    ]);
  }

  /// Get access token
  Future<String?> getAccessToken() async => _storage.read(key: _SessionKeys.accessToken);

  /// Get refresh token
  Future<String?> getRefreshToken() async => _storage.read(key: _SessionKeys.refreshToken);

  /// Clear all session (tokens + profile)
  Future<void> clearSession() async {
    accessToken = null;
    refreshToken = null;
    userId = null;
    username = null;
    email = null;
    fullName = null;
    role = null;
    avatarUrl = null;

    await Future.wait([
      _storage.delete(key: _SessionKeys.accessToken),
      _storage.delete(key: _SessionKeys.refreshToken),
      _storage.delete(key: _SessionKeys.userId),
      _storage.delete(key: _SessionKeys.username),
      _storage.delete(key: _SessionKeys.email),
      _storage.delete(key: _SessionKeys.fullName),
      _storage.delete(key: _SessionKeys.role),
      _storage.delete(key: _SessionKeys.avatarUrl),
    ]);
  }

  /// Check if user has session (used on app start)
  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}