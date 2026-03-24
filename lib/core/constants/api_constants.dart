/// ApiConstants
/// ─────────────────────────────────────────────
/// Định nghĩa endpoint + config liên quan API.
///
/// Không gọi API tại đây.
/// Chỉ định nghĩa path + status code + header key.
///
/// Tương thích với interceptor (refresh token flow).
///
/// Cách dùng:
/// dio.get(ApiConstants.login);
/// dio.post(ApiConstants.refreshToken);

class ApiConstants {
  ApiConstants._();

  /// ── BASE PATH ──────────────────────────────
  static const String apiPrefix = '/api';

  /// ── AUTH ───────────────────────────────────
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String logout = '$apiPrefix/auth/logout';
  static const String forgotPassword = '$apiPrefix/auth/forgot-password';
  static const String resetPassword = '$apiPrefix/auth/reset-password';
  static const String refreshToken = '$apiPrefix/auth/refresh-token';

  /// ── PROFILE ───────────────────────────────────
  static const String getProfile = '$apiPrefix/profile/getprofile';


  /// ── COMMON STATUS CODE ─────────────────────
  static const int success = 200;
  static const int created = 201;

  /// Dùng cho interceptor
  static const int unauthorized = 401;
  static const int forbidden = 403;

  /// ── HEADER KEYS ────────────────────────────
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';

  /// Header dùng để tránh loop refresh token
  /// (Interceptor sẽ check key này)
  static const String requiresAuth = 'requires_auth';

  /// ── CONTENT TYPE ───────────────────────────
  static const String applicationJson = 'application/json';
}