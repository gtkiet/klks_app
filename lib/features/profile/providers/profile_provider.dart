import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  bool _loading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;

  bool get hasData => _profile != null;

  /// =========================
  /// LOAD PROFILE
  /// =========================
  Future<void> loadProfile({bool force = false}) async {
    if (_profile != null && !force) return;

    _setLoading(true);

    try {
      final data = await ProfileService.getProfile();

      _profile = data;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _setLoading(false);
  }

  /// =========================
  /// REFRESH
  /// =========================
  Future<void> refresh() async {
    await loadProfile(force: true);
  }

  /// =========================
  /// UPDATE LOCAL
  /// =========================
  void updateProfile(UserProfile newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  /// =========================
  /// CLEAR (LOGOUT)
  /// =========================
  void clear() {
    _profile = null;
    _error = null;
    _loading = false;
    notifyListeners();
  }

  /// =========================
  /// PRIVATE
  /// =========================
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}