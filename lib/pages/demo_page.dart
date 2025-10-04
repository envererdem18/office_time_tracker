import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/check_in_out.dart';
import '../theme/app_theme.dart';
import '../widgets/atoms/demo_warning_widget.dart';
import '../widgets/molecules/custom_button.dart';
import '../widgets/molecules/greeting_card_widget.dart';
import '../widgets/molecules/status_message_widget.dart';
import '../widgets/molecules/today_status_card_widget.dart';

// Demo için state provider'lar (sadece UI için)
final demoHasCheckedInProvider = StateProvider<bool>((ref) => false);
final demoHasCheckedOutProvider = StateProvider<bool>((ref) => false);
final demoCheckInTimeProvider = StateProvider<DateTime?>((ref) => null);
final demoCheckOutTimeProvider = StateProvider<DateTime?>((ref) => null);

class DemoPage extends ConsumerStatefulWidget {
  const DemoPage({super.key});

  @override
  ConsumerState<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends ConsumerState<DemoPage> {
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;

  Future<void> _handleCheckIn() async {
    if (_isCheckingIn) return;

    setState(() {
      _isCheckingIn = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final now = DateTime.now();
      ref.read(demoHasCheckedInProvider.notifier).state = true;
      ref.read(demoCheckInTimeProvider.notifier).state = now;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo: Giriş kaydedildi! (Sadece gösterim amaçlı)'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
        });
      }
    }
  }

  Future<void> _handleCheckOut() async {
    if (_isCheckingOut) return;

    setState(() {
      _isCheckingOut = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final now = DateTime.now();
      ref.read(demoHasCheckedOutProvider.notifier).state = true;
      ref.read(demoCheckOutTimeProvider.notifier).state = now;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo: Çıkış kaydedildi! (Sadece gösterim amaçlı)'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }

  void _resetDemo() {
    ref.read(demoHasCheckedInProvider.notifier).state = false;
    ref.read(demoHasCheckedOutProvider.notifier).state = false;
    ref.read(demoCheckInTimeProvider.notifier).state = null;
    ref.read(demoCheckOutTimeProvider.notifier).state = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo sıfırlandı!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Günaydın! Bu demo sayfasında uygulamayı test edebilirsiniz.';
    } else if (hour < 18) {
      return 'İyi günler! Uygulamanın nasıl çalıştığını burada görebilirsiniz.';
    } else {
      return 'İyi akşamlar! Demo modunda uygulamayı keşfedin.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCheckedIn = ref.watch(demoHasCheckedInProvider);
    final hasCheckedOut = ref.watch(demoHasCheckedOutProvider);
    final checkInTime = ref.watch(demoCheckInTimeProvider);
    final checkOutTime = ref.watch(demoCheckOutTimeProvider);

    // Demo CheckInOut objesi oluştur
    CheckInOut? demoRecord;
    if (hasCheckedIn || hasCheckedOut) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      demoRecord = CheckInOut(
        date: todayDate,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Demo - Ofis Süre Takip'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetDemo,
            tooltip: 'Demo\'yu Sıfırla',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Demo uyarısı
              const DemoWarningWidget(),

              const SizedBox(height: 24),

              // Karşılama metni
              GreetingCardWidget(
                title: 'Demo Modunda!',
                message: _getGreetingMessage(),
                isDemo: true,
              ),

              const SizedBox(height: 32),

              // Giriş butonu
              CheckInButton(
                onPressed: hasCheckedIn ? null : _handleCheckIn,
                isEnabled: !hasCheckedIn,
                isLoading: _isCheckingIn,
              ),

              const SizedBox(height: 16),

              // Çıkış butonu
              CheckOutButton(
                onPressed: hasCheckedOut ? null : _handleCheckOut,
                isEnabled: hasCheckedIn && !hasCheckedOut,
                isLoading: _isCheckingOut,
              ),

              const SizedBox(height: 24),

              // Bugünkü durum kartı (demo)
              if (demoRecord != null)
                TodayStatusCardWidget(todayRecord: demoRecord, isDemo: true),

              // Durum mesajı
              StatusMessageWidget(
                hasCheckedIn: hasCheckedIn,
                hasCheckedOut: hasCheckedOut,
                isDemo: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
