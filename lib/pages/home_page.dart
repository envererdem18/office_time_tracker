import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/database_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/molecules/custom_button.dart';
import '../widgets/molecules/greeting_card_widget.dart';
import '../widgets/molecules/status_message_widget.dart';
import '../widgets/molecules/today_status_card_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;

  Future<void> _handleCheckIn() async {
    if (_isCheckingIn) return;

    setState(() {
      _isCheckingIn = true;
    });

    try {
      final checkInAction = ref.read(checkInActionProvider);
      await checkInAction();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giriş kaydedildi!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppTheme.errorColor),
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

    try {
      final checkOutAction = ref.read(checkOutActionProvider);
      await checkOutAction();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çıkış kaydedildi!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppTheme.errorColor),
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

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Günaydın! Yeni bir güne başlayalım.';
    } else if (hour < 18) {
      return 'İyi günler! Çalışmalarınız nasıl gidiyor?';
    } else {
      return 'İyi akşamlar! Günü tamamlamaya hazır mısınız?';
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayRecord = ref.watch(todayCheckInOutProvider);

    final bool hasCheckedIn = todayRecord?.checkInTime != null;
    final bool hasCheckedOut = todayRecord?.checkOutTime != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Ofis Süre Takip'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () => context.pushNamed(AppRoute.profile.name),
          tooltip: 'Profil',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () => context.pushNamed(AppRoute.demo.name),
            tooltip: 'Demo',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Karşılama metni
              GreetingCardWidget(title: 'Hoş Geldiniz!', message: _getGreetingMessage()),

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

              // Bugünkü durum kartı
              if (todayRecord != null) TodayStatusCardWidget(todayRecord: todayRecord),

              // Durum mesajı
              StatusMessageWidget(
                hasCheckedIn: hasCheckedIn,
                hasCheckedOut: hasCheckedOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
