import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/storage/user_session.dart';

class AuthService {
  final SecureStorage _storage = SecureStorage();

  // ================= REGISTER =================
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String idCard,
    required String dob,
    required int gioiTinhId,
    required String address,
  }) async {
    try {
      return await ApiClient.post(
        "/api/auth/register",
        body: {
          "username": username,
          "email": email,
          "password": password,
          "firstName": firstName,
          "lastName": lastName,
          "phoneNumber": phoneNumber,
          "idCard": idCard,
          "dob": dob,
          "gioiTinhId": gioiTinhId,
          "diaChi": address,
        },
      );
    } catch (e) {
      return _error("Lỗi kết nối");
    }
  }

  // ================= LOGIN =================
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final data = await ApiClient.post(
        "/api/auth/login",
        body: {"username": username, "password": password},
      );

      if (data["isOk"] == true && data["result"] != null) {
        final result = data["result"];

        // 1️⃣ Lưu token (secure)
        await _storage.saveTokens(
          accessToken: result["accessToken"],
          refreshToken: result["refreshToken"],
        );

        // 2️⃣ Lưu user (runtime)
        UserSession().setUserData(result);

        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  // ================= REFRESH TOKEN =================
  Future<bool> refreshAccessToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final data = await ApiClient.post(
        "/api/auth/refresh-token",
        body: {"refreshToken": refreshToken},
      );

      if (data["isOk"] == true && data["result"] != null) {
        final result = data["result"];

        // 1️⃣ Lưu lại token mới
        await _storage.saveTokens(
          accessToken: result["accessToken"],
          refreshToken: result["refreshToken"],
        );

        // 2️⃣ Update runtime token
        UserSession().updateTokens(
          accessToken: result["accessToken"],
          refreshToken: result["refreshToken"],
        );

        return true;
      }
    } catch (_) {}

    return false;
  }

  // ================= AUTO LOGIN =================
  Future<bool> tryAutoLogin() async {
    final tokens = await _storage.getTokens();

    final accessToken = tokens["accessToken"];
    final refreshToken = tokens["refreshToken"];

    if (accessToken == null) return false;

    // 1️⃣ Gán token vào session
    UserSession().updateTokens(
      accessToken: accessToken,
      refreshToken: refreshToken ?? "",
    );

    try {
      // 2️⃣ Lấy lại thông tin user
      final data = await ApiClient.get("/api/auth/me");

      if (data["isOk"] == true && data["result"] != null) {
        UserSession().setUserData({
          ...data["result"],
          "accessToken": accessToken,
          "refreshToken": refreshToken,
        });

        return true;
      }
    } catch (_) {
      // 3️⃣ Nếu token hết hạn → thử refresh
      return await refreshAccessToken();
    }

    return false;
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await ApiClient.post("/api/auth/logout", body: {});
    } catch (_) {}

    await _storage.clearTokens();
    UserSession().clear();
  }

  // ================= FORGOT PASSWORD =================
  Future<Map<String, dynamic>> forgotPassword({
    required String username,
  }) async {
    try {
      return await ApiClient.post(
        "/api/auth/forgot-password",
        body: {"username": username},
      );
    } catch (e) {
      return _error("Lỗi kết nối");
    }
  }

  // ================= RESET PASSWORD =================
  Future<Map<String, dynamic>> resetPassword({
    required String username,
    required String resetCode,
    required String newPassword,
  }) async {
    try {
      return await ApiClient.post(
        "/api/auth/reset-password",
        body: {
          "username": username,
          "resetCode": resetCode,
          "newPassword": newPassword,
        },
      );
    } catch (e) {
      return _error("Lỗi kết nối");
    }
  }

  // ================= HELPER =================
  Map<String, dynamic> _error(String message) {
    return {
      "isOk": false,
      "errors": [
        {"description": message}
      ]
    };
  }
}