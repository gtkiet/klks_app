// lib/core/storage/user_session.dart
//
// Session duy nhất của app — lưu token + thông tin user sau đăng nhập.
//
// FLOW SỬ DỤNG:
//   1. Đăng nhập thành công:
//        await UserSession.instance.save(userModel);
//
//   2. App khởi động lại:
//        await UserSession.instance.load();   // gọi trong main() hoặc splash
//        if (!UserSession.instance.isLoggedIn) → chuyển màn login
//
//   3. Đăng xuất:
//        await UserSession.instance.clear();
//
//   4. Lấy dữ liệu (sync, không cần await sau khi load()):
//        UserSession.instance.accessToken
//        UserSession.instance.fullName
//        UserSession.instance.anhDaiDienUrl
//
// TRONG HOME SCREEN — không cần HomeService hay HomeData:
//   final session = UserSession.instance;
//   Text(session.fullName ?? 'Người dùng');
//   CachedNetworkImage(url: session.anhDaiDienUrl ?? '');

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/models/user_model.dart';

// ── Keys ─────────────────────────────────────────────────────────────────────

abstract class _K {
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

// ── Session ───────────────────────────────────────────────────────────────────

class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  final _storage = const FlutterSecureStorage();

  // ── In-memory cache (sync access sau khi load()) ──────────────────────────

  String? accessToken;
  String? refreshToken;
  String? userId;
  String? accountId;
  String? username;
  String? email;
  String? fullName;
  String? role;
  String? anhDaiDienUrl;

  bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  // ── Khởi động app ────────────────────────────────────────────────────────

  /// Gọi một lần trong `main()` hoặc Splash screen trước khi routing.
  /// Sau khi load() xong, mọi field đều sync — không cần await nữa.
  Future<void> load() async {
    final values = await Future.wait([
      _storage.read(key: _K.accessToken),
      _storage.read(key: _K.refreshToken),
      _storage.read(key: _K.userId),
      _storage.read(key: _K.accountId),
      _storage.read(key: _K.username),
      _storage.read(key: _K.email),
      _storage.read(key: _K.fullName),
      _storage.read(key: _K.role),
      _storage.read(key: _K.anhDaiDienUrl),
    ]);

    accessToken = values[0];
    refreshToken = values[1];
    userId = values[2];
    accountId = values[3];
    username = values[4];
    email = values[5];
    fullName = values[6];
    role = values[7];
    anhDaiDienUrl = values[8];
  }

  // ── Đăng nhập ────────────────────────────────────────────────────────────

  /// Lưu toàn bộ thông tin từ [UserModel] sau khi đăng nhập thành công.
  Future<void> save(UserModel user) async {
    // Cập nhật in-memory trước để UI có thể đọc ngay
    accessToken = user.accessToken;
    refreshToken = user.refreshToken;
    userId = user.userId.toString();
    accountId = user.accountId.toString();
    username = user.username;
    email = user.email;
    fullName = user.fullName;
    role = user.role;
    anhDaiDienUrl = user.anhDaiDienUrl;

    await Future.wait([
      _storage.write(key: _K.accessToken, value: user.accessToken),
      _storage.write(key: _K.refreshToken, value: user.refreshToken),
      _storage.write(key: _K.userId, value: user.userId.toString()),
      _storage.write(key: _K.accountId, value: user.accountId.toString()),
      _storage.write(key: _K.username, value: user.username),
      _storage.write(key: _K.email, value: user.email),
      _storage.write(key: _K.fullName, value: user.fullName),
      _storage.write(key: _K.role, value: user.role),
      _storage.write(key: _K.anhDaiDienUrl, value: user.anhDaiDienUrl),
    ]);
  }

  // ── Cập nhật token (sau khi refresh) ─────────────────────────────────────

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    await Future.wait([
      _storage.write(key: _K.accessToken, value: accessToken),
      _storage.write(key: _K.refreshToken, value: refreshToken),
    ]);
  }

  // ── Cập nhật avatar ───────────────────────────────────────────────────────

  Future<void> updateAvatar(String newUrl) async {
    anhDaiDienUrl = newUrl;
    await _storage.write(key: _K.anhDaiDienUrl, value: newUrl);
  }

  // ── Đăng xuất ────────────────────────────────────────────────────────────

  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    userId = null;
    accountId = null;
    username = null;
    email = null;
    fullName = null;
    role = null;
    anhDaiDienUrl = null;

    await _storage.deleteAll();
  }
}