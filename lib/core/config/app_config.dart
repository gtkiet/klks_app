// lib/core/config/app_config.dart

/// AppConfig
/// ─────────────────────────────────────────────
/// Cấu hình toàn cục cho ứng dụng.
/// Không chứa logic, chỉ định nghĩa giá trị và môi trường.
///
/// Cách dùng:
/// AppConfig.baseUrl
/// AppConfig.isDebug
/// AppConfig.connectTimeout

class AppConfig {
  AppConfig._(); // prevent instantiation

  /// ── API ─────────────────────────────────────
  static const String baseUrl =
      "https://chungcu-webapi-fwf7cva4c7c6ajae.eastasia-01.azurewebsites.net";

  /// ── TIMEOUT CONFIG (seconds) ───────────
  static const int timeout = 10;

  /// ── TOKEN CONFIG ────────────────────────────
  /// Access token expire: 1 hour
  static const Duration accessTokenExpiry = Duration(hours: 1);

  /// ── PAGINATION DEFAULT ──────────────────────
  static const int defaultPage = 1;
  static const int defaultPageSize = 20;

  /// ── APP INFO ────────────────────────────────
  static const String appName = 'PKK - Chung cư thông minh';
}
