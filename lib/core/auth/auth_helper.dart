import '../../config/app_routes.dart';
import '../../main.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/services/auth_service.dart';

class AuthHelper {
  static final SecureStorage _storage = SecureStorage();
  static final AuthService _authService = AuthService();

  // =========================
  // 🔥 FORCE LOGOUT (GLOBAL)
  // =========================
  static Future<void> forceLogout() async {
    try {
      await _storage.clearTokens();
    } catch (_) {}

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  // =========================
  // 🔹 LOGOUT (CÓ API)
  // =========================
  static Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // ignore lỗi API
    }

    await forceLogout();
  }
}