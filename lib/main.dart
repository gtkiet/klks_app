import 'package:flutter/material.dart';
import 'config/app_routes.dart';

/// 🔥 GLOBAL NAVIGATOR (dùng cho logout global)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const KLKSApp());
}

class KLKSApp extends StatelessWidget {
  const KLKSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,

      title: 'KLKS Resident App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        useMaterial3: true,
      ),

      /// 🔥 LUÔN đi qua splash
      initialRoute: AppRoutes.splash,

      routes: AppRoutes.routes,
    );
  }
}