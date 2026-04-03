// core/storage/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._internal();

  static final SecureStorage _instance = SecureStorage._internal();

  factory SecureStorage() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Write value securely
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  /// Read value securely
  Future<String?> read({required String key}) async {
    return _storage.read(key: key);
  }

  /// Delete a specific key
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  /// Clear all secure storage
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
