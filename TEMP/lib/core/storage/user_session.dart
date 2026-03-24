class UserSession {
  // =========================
  // 🔒 Singleton
  // =========================
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  // =========================
  // 👤 USER INFO
  // =========================
  int? userId;
  String? username;
  String? email;
  String? fullName;
  String? role;
  String? avatarUrl;

  // =========================
  // 🔑 TOKENS (runtime only)
  // =========================
  String? accessToken;
  String? refreshToken;

  // =========================
  // 📥 SET DATA FROM API
  // =========================
  void setUserData(Map<String, dynamic> data) {
    userId = data['userId'];
    username = data['username'];
    email = data['email'];
    fullName = data['fullName'];
    role = data['role'];
    avatarUrl = data['anhDaiDienUrl'];

    // Token có thể có hoặc không (ví dụ /me không trả token)
    accessToken = data['accessToken'] ?? accessToken;
    refreshToken = data['refreshToken'] ?? refreshToken;
  }

  // =========================
  // 🧹 CLEAR SESSION
  // =========================
  void clear() {
    userId = null;
    username = null;
    email = null;
    fullName = null;
    role = null;
    avatarUrl = null;
    accessToken = null;
    refreshToken = null;
  }

  // =========================
  // ✅ CHECK LOGIN
  // =========================
  bool get isLoggedIn =>
      accessToken != null && accessToken!.isNotEmpty;

  // =========================
  // 🛠 UPDATE TOKEN (khi refresh)
  // =========================
  void updateTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}