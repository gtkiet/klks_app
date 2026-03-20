import 'package:flutter/material.dart';
import 'config/app_routes.dart';

/// 🔥 GLOBAL NAVIGATOR (logout, force redirect, ...)
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KLKSApp());
}

class KLKSApp extends StatelessWidget {
  const KLKSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // =========================
      // GLOBAL NAVIGATION
      // =========================
      navigatorKey: navigatorKey,

      // =========================
      // APP CONFIG
      // =========================
      title: 'KLKS Resident App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        useMaterial3: true,
      ),

      // =========================
      // INITIAL ROUTE
      // =========================
      initialRoute: AppRoutes.splash,

      // =========================
      // ROUTING
      // =========================
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,

      // 🔥 fallback nếu route sai
      onUnknownRoute: (settings) =>
          AppRoutes.onGenerateRoute(settings),

      // =========================
      // GLOBAL BUILDER
      // =========================
      builder: (context, child) {
        return GestureDetector(
          // 👉 Ẩn keyboard khi tap ra ngoài
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}