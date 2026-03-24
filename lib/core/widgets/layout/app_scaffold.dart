// file: lib/core/widgets/layout/app_scaffold.dart

import 'package:flutter/material.dart';
import '../loading/app_loading.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final bool loading;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.loading = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null ? AppBar(title: Text(title!)) : null,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          body,

          if (loading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                // child: CircularProgressIndicator(),
                child: AppLoading(),
              ),
            ),
        ],
      ),
    );
  }
}