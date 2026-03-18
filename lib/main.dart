import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_routes.dart';
import 'core/network/api_client.dart'; // 👈 thêm
import 'features/auth/providers/auth_provider.dart';
import 'features/profile/providers/profile_provider.dart';

/// 🔥 GLOBAL NAVIGATOR
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const AppProviders(child: KLKSApp()));
}

/// =========================
/// PROVIDER WRAPPER (SCALE)
/// =========================
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();

            /// 🔥 CỰC KỲ QUAN TRỌNG
            ApiClient.setAuthProvider(authProvider);

            return authProvider;
          },
        ),

        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),
      ],
      child: child,
    );
  }
}

/// =========================
/// MAIN APP
/// =========================
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),

      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}