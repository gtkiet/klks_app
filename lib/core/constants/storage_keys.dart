/// StorageKeys
/// ─────────────────────────────────────────────
/// Key dùng chung cho local storage (SharedPreferences, SecureStorage, v.v.)
///
/// QUY TẮC:
/// - Không hardcode string ở nơi khác
/// - Tất cả key phải nằm ở đây
///
/// Cách dùng:
/// storage.read(StorageKeys.accessToken)

class StorageKeys {
  StorageKeys._();

  /// ── AUTH ───────────────────────────────────
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';
}
