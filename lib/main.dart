import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'services/database_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar ve navigation bar renkleri
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Hive veritabanını başlat
  final databaseService = DatabaseService();
  await databaseService.init();

  databaseService.debugBoxStatus();

  runApp(ProviderScope(child: const OfficeTimeTrackerApp()));
}

class OfficeTimeTrackerApp extends StatelessWidget {
  const OfficeTimeTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ofis Giriş-Çıkış Takip',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
