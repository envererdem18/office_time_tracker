import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/check_in_out.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

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

    // 1 saniye simüle et
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

    // 1 saniye simüle et
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.warningColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bu demo sayfasıdır. Veriler gerçek veritabanına kaydedilmez.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
                      'Demo Modunda!',
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

              // Bugünkü durum kartı (demo)
              if (demoRecord != null) _buildTodayStatusCard(demoRecord),

              // Durum mesajı
              _buildStatusMessage(hasCheckedIn, hasCheckedOut),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayStatusCard(CheckInOut demoRecord) {
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
          Row(
            children: [
              Text(
                'Demo Durum',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'DEMO',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  'Giriş',
                  demoRecord.checkInTimeString,
                  AppTheme.checkInColor,
                  Icons.login,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeInfo(
                  'Çıkış',
                  demoRecord.checkOutTimeString,
                  AppTheme.checkOutColor,
                  Icons.logout,
                ),
              ),
            ],
          ),
          if (demoRecord.workDuration != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Toplam: ${demoRecord.workDurationString}',
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
      message = 'Demo: Giriş yapmak için yeşil butona basın';
      color = AppTheme.checkInColor;
      icon = Icons.info_outline;
    } else if (!hasCheckedOut) {
      message = 'Demo: Çıkış yapmayı unutmayın!';
      color = AppTheme.warningColor;
      icon = Icons.warning_amber_outlined;
    } else {
      message = 'Demo: Günün kaydı tamamlandı. Sıfırla butonuna basarak tekrar deneyin!';
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
      return 'Günaydın! Bu demo sayfasında uygulamayı test edebilirsiniz.';
    } else if (hour < 18) {
      return 'İyi günler! Uygulamanın nasıl çalıştığını burada görebilirsiniz.';
    } else {
      return 'İyi akşamlar! Demo modunda uygulamayı keşfedin.';
    }
  }
}
