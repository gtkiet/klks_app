// lib/app.dart

import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}