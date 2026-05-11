// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/guards/auth_guard.dart';
import 'core/storage/user_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await UserSession.instance.load();

  await AuthGuard.instance.init();

  runApp(const App());
}
