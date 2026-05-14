// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/storage/user_session.dart';
// import 'core/guards/auth_guard.dart';
import 'core/navigation/app_router.dart';

import 'design/design.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await UserSession.instance.load();

  // await AuthGuard.instance.init();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,

      debugShowCheckedModeBanner: false,

      routerConfig: AppRouter.router,

      // ── Apply the design system theme ──────────────────────────────────────
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
    );
  }
}
