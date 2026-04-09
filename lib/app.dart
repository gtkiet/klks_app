// lib/app.dart

import 'package:flutter/material.dart';
import 'design/design.dart';
import 'core/navigation/app_router.dart';

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
      // darkTheme: AppTheme.dark,  // Uncomment when dark mode is implemented.
      themeMode: ThemeMode.light,
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
    );
  }
}