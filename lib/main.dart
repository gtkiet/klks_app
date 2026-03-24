// lib/main.dart

import 'package:flutter/material.dart';

import 'app.dart';
import 'core/guards/auth_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthGuard.instance.init();

  runApp(const App());
}
