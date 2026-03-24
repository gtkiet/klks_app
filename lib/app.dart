// lib/app.dart

import 'package:flutter/material.dart';

import 'core/controllers/loading_controller.dart';
import 'routes/app_router.dart';
import 'core/theme/theme.dart';
import 'core/widgets/widgets.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return _AppOverlay(child: child ?? const SizedBox());
      },
    );
  }
}

class _AppOverlay extends StatelessWidget {
  final Widget child;

  const _AppOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LoadingController.instance,
      builder: (_, _) {
        final isLoading = LoadingController.instance.isLoading;

        return Stack(children: [child, if (isLoading) const _GlobalLoading()]);
      },
    );
  }
}

class _GlobalLoading extends StatelessWidget {
  const _GlobalLoading();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: const AppLoading(),
        ),
      ),
    );
  }
}
