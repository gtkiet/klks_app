// lib/core/storage/user_session.dart

import 'secure_storage.dart';

class _SessionKeys {
  static const accessToken = 'accessToken';
  static const refreshToken = 'refreshToken';

  static const userId = 'userId';
  static const accountId = 'accountId';
  static const username = 'username';
  static const email = 'email';
  static const fullName = 'fullName';
  static const role = 'role';
  static const anhDaiDienUrl = 'anhDaiDienUrl';
}

class UserSession {
  UserSession._internal();
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;

  final SecureStorage _storage = SecureStorage();

  String? accessToken;
  String? refreshToken;

  String? userId;
  String? accountId;
  String? username;
  String? email;
  String? fullName;
  String? role;
  String? anhDaiDienUrl;

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

  Future<void> saveProfile({
    required String userId,
    required String accountId,
    required String username,
    required String email,
    required String fullName,
    required String role,
    required String anhDaiDienUrl,
  }) async {
    this.userId = userId;
    this.accountId = accountId;
    this.username = username;
    this.email = email;
    this.fullName = fullName;
    this.role = role;
    this.anhDaiDienUrl = anhDaiDienUrl;

    await Future.wait([
      _storage.write(key: _SessionKeys.userId, value: userId),
      _storage.write(key: _SessionKeys.accountId, value: accountId),
      _storage.write(key: _SessionKeys.username, value: username),
      _storage.write(key: _SessionKeys.email, value: email),
      _storage.write(key: _SessionKeys.fullName, value: fullName),
      _storage.write(key: _SessionKeys.role, value: role),
      _storage.write(key: _SessionKeys.anhDaiDienUrl, value: anhDaiDienUrl),
    ]);
  }

  Future<String?> getAccessToken() async =>
      _storage.read(key: _SessionKeys.accessToken);

  Future<String?> getRefreshToken() async =>
      _storage.read(key: _SessionKeys.refreshToken);

  Future<String?> getFullName() async =>
      fullName ?? await _storage.read(key: _SessionKeys.fullName);

  Future<String?> getanhDaiDienUrl() async =>
      anhDaiDienUrl ?? await _storage.read(key: _SessionKeys.anhDaiDienUrl);

  Future<String?> getEmail() async =>
      email ?? await _storage.read(key: _SessionKeys.email);
  
  Future<String?> getRole() async =>
      role ?? await _storage.read(key: _SessionKeys.role);

  Future<void> updateAvatar(String newUrl) async {
    anhDaiDienUrl = newUrl;

    await _storage.write(key: _SessionKeys.anhDaiDienUrl, value: newUrl);
  }

  Future<void> clearSession() async {
    accessToken = null;
    refreshToken = null;
    userId = null;
    username = null;
    email = null;
    fullName = null;
    role = null;
    anhDaiDienUrl = null;

    await Future.wait([
      _storage.delete(key: _SessionKeys.accessToken),
      _storage.delete(key: _SessionKeys.refreshToken),
      _storage.delete(key: _SessionKeys.userId),
      _storage.delete(key: _SessionKeys.accountId),
      _storage.delete(key: _SessionKeys.username),
      _storage.delete(key: _SessionKeys.email),
      _storage.delete(key: _SessionKeys.fullName),
      _storage.delete(key: _SessionKeys.role),
      _storage.delete(key: _SessionKeys.anhDaiDienUrl),
    ]);
  }

  Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
