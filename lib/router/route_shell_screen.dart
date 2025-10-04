import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'bottom_bar.dart';

class RouteShellScreen extends StatelessWidget {
  final StatefulNavigationShell shell;
  final String? path;
  const RouteShellScreen({super.key, required this.shell, this.path});

  void _onTap(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: BottomBar(
        currentIndex: shell.currentIndex,
        onTap: (index) => _onTap(index),
      ),
    );
  }
}
