import '../../../core/guards/auth_guard.dart';
import '../../../core/storage/user_session.dart';
import '../models/home_data.dart';

class HomeService {
  HomeService._();

  static final HomeService instance = HomeService._();

  final UserSession _session = UserSession();

  Future<HomeData> getHomeData() async {
    try {
      final fullName = await _session.getFullName();
      final anhDaiDienUrl = await _session.getanhDaiDienUrl();

      return HomeData(
        fullName: (fullName != null && fullName.isNotEmpty)
            ? fullName
            : 'Người dùng',
        anhDaiDienUrl: anhDaiDienUrl,
      );
    } catch (e) {
      return const HomeData(fullName: 'Người dùng', anhDaiDienUrl: null);
    }
  }

  Future<void> logout() async {
    await _session.clearSession();
    AuthGuard.instance.logout();
  }
}
