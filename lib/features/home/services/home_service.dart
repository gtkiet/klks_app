import '../../../core/guards/auth_guard.dart';
import '../../auth/services/auth_service.dart';
import '../../profile/services/profile_service.dart';
import '../models/home_data.dart';

/// ─────────────────────────────────────────────────────────
/// HomeService
///
/// Cung cấp dữ liệu cho HomeScreen.
/// Hiện tại dùng ProfileService để lấy profile thực tế.
/// Nếu có lỗi (API chưa sẵn sàng, mạng lỗi...), fallback về mock data.
///
/// Có thể mở rộng thêm các dữ liệu khác như:
/// - Notifications
/// - Dashboard stats
/// - Banner / Slider data
/// ─────────────────────────────────────────────────────────
class HomeService {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  /// Lấy data cho HomeScreen
  /// Trả về HomeData bao gồm fullName và avatarUrl
  Future<HomeData> getHomeData() async {
    try {
      // Lấy profile từ backend
      final profile = await _profileService.getProfile();

      // Trả về dữ liệu thực tế nếu có
      return HomeData(
        fullName: profile?.fullName ?? 'Người dùng',
        avatarUrl: profile?.anhDaiDienUrl,
      );
    } catch (e) {
      // Trường hợp lỗi API hoặc exception, trả fallback
      return const HomeData(
        fullName: 'Người dùng',
        avatarUrl: null,
      );
    }
  }

  /// Logout user
  /// - Gọi AuthService để clear session / token
  /// - Gọi AuthGuard để redirect về login nếu cần
  Future<void> logout() async {
    await _authService.logout();
    AuthGuard.instance.logout();
  }
}