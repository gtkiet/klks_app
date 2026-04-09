/// PKK Resident - Global Constants
///
/// App-wide constants that don't belong to a specific feature.
abstract final class AppConstants {
  // App identity
  static const String appName = 'PKK Resident';

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);

  // Input constraints
  static const int maxPasswordLength = 32;
  static const int maxInputLength = 255;

  // Layout constraints
  static const double maxContentWidth = 600.0;
  static const double bottomNavHeight = 64.0;
  static const double appBarHeight = 56.0;

  // Loading spinner size
  static const double spinnerSize = 20.0;
  static const double spinnerStrokeWidth = 2.0;
}
