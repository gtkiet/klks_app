/// routes/app_routes.dart
///
/// Centralized route names for the entire app.
///
/// Mục tiêu:
/// - Tránh hard-code string
/// - Dễ refactor
/// - Dễ scale
///
/// Usage:
/// Navigator.pushNamed(context, AppRoutes.login);

class AppRoutes {
  AppRoutes._();

  // ── AUTH ─────────────────────────────
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgotPassword';

  // ── MAIN ─────────────────────────────
  static const String main = '/main';
  static const String home = '/home';

  static const String profile = '/profile';
  
  static const String bill = '/bill';
  static const String service = '/service';
  static const String community = '/community';

  static const String changePassword = '/change-password';
  static const String residences = '/residences';

  // ── COMMON ───────────────────────────
  static const String splash = '/splash';

  /// Entry point của app
  static const String initial = splash;
}
