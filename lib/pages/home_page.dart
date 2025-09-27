import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () => context.pushNamed('demo'),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(Icons.business, size: 48, color: AppTheme.primaryColor),
                    const SizedBox(height: 12),
                    Text(
                      'Hoş Geldiniz!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getGreetingMessage(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondaryColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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

              // Bugünkü durum kartı
              if (todayRecord != null) _buildTodayStatusCard(todayRecord),

              // Durum mesajı
              _buildStatusMessage(hasCheckedIn, hasCheckedOut),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStatusCard(dynamic todayRecord) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bugünkü Durum',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  'Giriş',
                  todayRecord.checkInTimeString,
                  AppTheme.checkInColor,
                  Icons.login,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeInfo(
                  'Çıkış',
                  todayRecord.checkOutTimeString,
                  AppTheme.checkOutColor,
                  Icons.logout,
                ),
              ),
            ],
          ),
          if (todayRecord.workDuration != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Toplam: ${todayRecord.workDurationString}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(bool hasCheckedIn, bool hasCheckedOut) {
    String message;
    Color color;
    IconData icon;

    if (!hasCheckedIn) {
      message = 'Giriş yapmak için yeşil butona basın';
      color = AppTheme.checkInColor;
      icon = Icons.info_outline;
    } else if (!hasCheckedOut) {
      message = 'Çıkış yapmayı unutmayın!';
      color = AppTheme.warningColor;
      icon = Icons.warning_amber_outlined;
    } else {
      message = 'Günün kaydı tamamlandı. İyi günler!';
      color = AppTheme.successColor;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
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
}
