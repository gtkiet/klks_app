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
  Future<Map<String, dynamic>> refreshAccessToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return {
        "success": false,
        "errors": [
          {"description": "Refresh token không tồn tại"},
        ],
      };
    }

    try {
      final data = await ApiClient.post(
        "/api/auth/refresh-token",
        body: {"refreshToken": refreshToken},
      );

      if (data["isOk"] == true && data["result"] != null) {
        final result = data["result"];

        // 1️⃣ Lưu token mới
        await _storage.saveTokens(
          accessToken: result["accessToken"],
          refreshToken: result["refreshToken"],
        );

        // 2️⃣ Update runtime token & user info
        UserSession().updateTokens(
          accessToken: result["accessToken"],
          refreshToken: result["refreshToken"],
        );

        UserSession().setUserData({
          "userId": result["userId"],
          "username": result["username"],
          "email": result["email"],
          "anhDaiDienUrl": result["anhDaiDienUrl"],
          "role": result["role"],
          "fullName": result["fullName"],
        });

        return {
          "success": true,
          "data": result,
          "warnings": data["warningMessages"] ?? [],
        };
      } else {
        return {
          "success": false,
          "errors":
              data["errors"] ??
              [
                {"description": "Lỗi không xác định khi refresh token"},
              ],
        };
      }
    } catch (e) {
      return {
        "success": false,
        "errors": [
          {"description": "Lỗi kết nối: ${e.toString()}"},
        ],
      };
    }
  }

  // ================= AUTO LOGIN =================
  Future<Map<String, dynamic>> tryAutoLogin() async {
    final tokens = await _storage.getTokens();

    final accessToken = tokens["accessToken"];
    final refreshToken = tokens["refreshToken"];

    if (accessToken != null) {
      // 1️⃣ Gán token vào session
      UserSession().updateTokens(
        accessToken: accessToken,
        refreshToken: refreshToken ?? "",
      );
      return {"success": true};
    }

    // 2️⃣ Nếu không có accessToken nhưng có refreshToken → thử refresh
    if (refreshToken != null && refreshToken.isNotEmpty) {
      final result = await refreshAccessToken();
      return result; // result["success"] = true/false
    }

    // 3️⃣ Không token nào hợp lệ → chưa login
    return {"success": false};
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
        {"description": message},
      ],
    };
  }
}
