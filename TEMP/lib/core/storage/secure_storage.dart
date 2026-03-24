import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // =========================
  // 🔒 Singleton
  // =========================
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // =========================
  // 🔑 KEYS
  // =========================
  static const String _accessTokenKey = "accessToken";
  static const String _refreshTokenKey = "refreshToken";

  // =========================
  // 💾 SAVE TOKENS (QUAN TRỌNG NHẤT)
  // =========================
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  // =========================
  // 📥 GET TOKENS
  // =========================
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  // 👉 Lấy cả 2 cùng lúc (rất hữu ích)
  Future<Map<String, String?>> getTokens() async {
    final results = await Future.wait([
      _storage.read(key: _accessTokenKey),
      _storage.read(key: _refreshTokenKey),
    ]);

    return {
      "accessToken": results[0],
      "refreshToken": results[1],
    };
  }

  // =========================
  // 🗑 CLEAR TOKENS
  // =========================
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  // =========================
  // ❌ CLEAR ALL (DEBUG)
  // =========================
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}