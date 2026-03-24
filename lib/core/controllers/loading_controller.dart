// lib/core/controllers/loading_controller.dart

import 'package:flutter/material.dart';

class LoadingController extends ChangeNotifier {
  static final LoadingController instance = LoadingController._();

  LoadingController._();

  int _count = 0;

  bool get isLoading => _count > 0;

  void show() {
    _count++;
    notifyListeners();
  }

  void hide() {
    if (_count <= 0) return;

    _count--;

    if (_count == 0) {
      notifyListeners();
    }
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}
