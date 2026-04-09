// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/guards/auth_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await AuthGuard.instance.init();

  runApp(const App());
}

// import 'package:flutter/material.dart';
// import 'design/design.dart';

// void main() {
//   runApp(const PKKResidentApp());
// }

// class PKKResidentApp extends StatelessWidget {
//   const PKKResidentApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: AppConstants.appName,
//       debugShowCheckedModeBanner: false,

//       // ── Apply the design system theme ──────────────────────────────────────
//       theme: AppTheme.light,
//       // darkTheme: AppTheme.dark,  // Uncomment when dark mode is implemented.
//       themeMode: ThemeMode.light,

//       // ── Routes ────────────────────────────────────────────────────────────
//       initialRoute: '/',
//       routes: {
//         '/': (_) => const DesignDemoScreen(), // Replace with your HomeScreen
//         '/design-demo': (_) => const DesignDemoScreen(),
//       },
//     );
//   }
// }
