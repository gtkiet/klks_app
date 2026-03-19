import 'dart:io';
import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../../../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  // =========================
  // GETTERS
  // =========================
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _profile != null;

  // =========================
  // LOAD PROFILE
  // =========================
  Future<void> loadProfile({bool force = false}) async {
    if (_profile != null && !force) return;

    _setLoading(true);
    _error = null;

    try {
      final res = await _service.getProfile();
      if (res.isOk && res.data != null) {
        _profile = res.data;
      } else {
        _error = res.message;
      }
    } catch (e) {
      _error = "Lỗi kết nối: $e";
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // REFRESH PROFILE
  // =========================
  Future<void> refresh() async {
    await loadProfile(force: true);
  }

  // =========================
  // UPDATE PROFILE
  // =========================
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String idCard,
    required DateTime dob,
    required int gioiTinhId,
    required String diaChi,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final res = await _service.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        idCard: idCard,
        dob: dob,
        gioiTinhId: gioiTinhId,
        diaChi: diaChi,
      );

      if (res.isOk && res.data != null) {
        _profile = res.data;
        return true;
      } else {
        _error = res.message;
        return false;
      }
    } catch (e) {
      _error = "Lỗi kết nối: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // CHANGE AVATAR
  // =========================
  Future<bool> changeAvatar(File file) async {
    _setLoading(true);
    _error = null;

    try {
      final res = await _service.changeAvatar(file);
      if (res.isOk && res.data != null) {
        if (_profile != null) {
          _profile = _profile!.copyWith(anhDaiDienUrl: res.data);
        }
        return true;
      } else {
        _error = res.message;
        return false;
      }
    } catch (e) {
      _error = "Lỗi kết nối: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // UPDATE LOCAL PROFILE
  // =========================
  void updateLocalProfile(UserProfile newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  // =========================
  // CLEAR (LOGOUT)
  // =========================
  void clear() {
    _profile = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // =========================
  // PRIVATE HELPERS
  // =========================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}