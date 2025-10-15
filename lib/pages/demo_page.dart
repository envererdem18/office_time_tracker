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
final demoCommuteDepartureTimeProvider = StateProvider<DateTime?>((ref) => null);
final demoReturnArrivalTimeProvider = StateProvider<DateTime?>((ref) => null);
final demoCommuteTrackingEnabledProvider = StateProvider<bool>((ref) => false);

class DemoPage extends ConsumerStatefulWidget {
  const DemoPage({super.key});

  @override
  ConsumerState<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends ConsumerState<DemoPage> {
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  bool _isStartingCommute = false;
  bool _isCompletingReturn = false;

  Future<void> _handleStartCommute() async {
    if (_isStartingCommute) return;

    setState(() {
      _isStartingCommute = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final now = DateTime.now();
      ref.read(demoCommuteDepartureTimeProvider.notifier).state = now;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo: Yola çıkış kaydedildi! (Sadece gösterim amaçlı)'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStartingCommute = false;
        });
      }
    }
  }

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

  Future<void> _handleCompleteReturn() async {
    if (_isCompletingReturn) return;

    setState(() {
      _isCompletingReturn = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    try {
      final now = DateTime.now();
      ref.read(demoReturnArrivalTimeProvider.notifier).state = now;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demo: Dönüş tamamlandı! (Sadece gösterim amaçlı)'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompletingReturn = false;
        });
      }
    }
  }

  void _resetDemo() {
    ref.read(demoHasCheckedInProvider.notifier).state = false;
    ref.read(demoHasCheckedOutProvider.notifier).state = false;
    ref.read(demoCheckInTimeProvider.notifier).state = null;
    ref.read(demoCheckOutTimeProvider.notifier).state = null;
    ref.read(demoCommuteDepartureTimeProvider.notifier).state = null;
    ref.read(demoReturnArrivalTimeProvider.notifier).state = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo sıfırlandı!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _toggleCommuteTracking() {
    final currentValue = ref.read(demoCommuteTrackingEnabledProvider);
    ref.read(demoCommuteTrackingEnabledProvider.notifier).state = !currentValue;

    // Yol hesaplama açıldığında veya kapatıldığında demo'yu sıfırla
    _resetDemo();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !currentValue ? 'Yol hesaplama açıldı!' : 'Yol hesaplama kapatıldı!',
        ),
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
    final commuteDepartureTime = ref.watch(demoCommuteDepartureTimeProvider);
    final returnArrivalTime = ref.watch(demoReturnArrivalTimeProvider);
    final commuteTrackingEnabled = ref.watch(demoCommuteTrackingEnabledProvider);

    final bool hasCommuteDeparture = commuteDepartureTime != null;
    final bool hasReturnArrival = returnArrivalTime != null;

    // Demo CheckInOut objesi oluştur
    CheckInOut? demoRecord;
    if (hasCheckedIn || hasCheckedOut || hasCommuteDeparture || hasReturnArrival) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      demoRecord = CheckInOut(
        date: todayDate,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        commuteDepartureTime: commuteDepartureTime,
        returnArrivalTime: returnArrivalTime,
      );
    }

    // Bugün için herhangi bir aksiyon alınmış mı kontrol et
    final bool hasTodayAction =
        demoRecord != null &&
        (demoRecord.commuteDepartureTime != null ||
            demoRecord.checkInTime != null ||
            demoRecord.checkOutTime != null ||
            demoRecord.returnArrivalTime != null);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Demo - Ofis Süre Takip'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              commuteTrackingEnabled
                  ? Icons.directions_car
                  : Icons.directions_car_outlined,
              color: commuteTrackingEnabled ? AppTheme.successColor : null,
            ),
            onPressed: _toggleCommuteTracking,
            tooltip: commuteTrackingEnabled
                ? 'Yol Hesaplama Açık'
                : 'Yol Hesaplama Kapalı',
          ),
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

              // Tek buton mantığı - duruma göre değişir
              // Yol hesaplama kapalı - normal akış (Giriş -> Çıkış)
              if (!commuteTrackingEnabled && !hasCheckedOut) ...[
                if (!hasCheckedIn)
                  CheckInButton(
                    onPressed: _handleCheckIn,
                    isEnabled: true,
                    isLoading: _isCheckingIn,
                  )
                else
                  CheckOutButton(
                    onPressed: _handleCheckOut,
                    isEnabled: true,
                    isLoading: _isCheckingOut,
                  ),
              ]
              // Yol hesaplama açık - yol takip akışı (Yola Çık -> Giriş Yap -> Çıkış Yap -> Dönüşü Tamamla)
              else if (commuteTrackingEnabled) ...[
                // 1. Adım: Yol takibi başlatılmamışsa → Yola Çık
                if (!hasCommuteDeparture) ...[
                  // Bugün için herhangi bir kayıt varsa buton disabled
                  if (hasTodayAction)
                    Column(
                      children: [
                        StartCommuteButton(
                          onPressed: null, // Disabled - widget otomatik gri yapacak
                          isEnabled: false,
                          isLoading: false,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Yol hesaplama yarından itibaren geçerli olacak',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  // Bugün için hiç kayıt yoksa buton aktif
                  else
                    StartCommuteButton(
                      onPressed: _handleStartCommute,
                      isEnabled: true,
                      isLoading: _isStartingCommute,
                    ),
                ]
                // 2. Adım: Yola çıkıldı ama giriş yapılmadıysa → Giriş Yap
                else if (!hasCheckedIn)
                  CheckInButton(
                    onPressed: _handleCheckIn,
                    isEnabled: true,
                    isLoading: _isCheckingIn,
                  )
                // 3. Adım: Giriş yapıldı ama çıkış yapılmadıysa → Çıkış Yap
                else if (!hasCheckedOut)
                  CheckOutButton(
                    onPressed: _handleCheckOut,
                    isEnabled: true,
                    isLoading: _isCheckingOut,
                  )
                // 4. Adım: Çıkış yapıldı ama dönüş tamamlanmadıysa → Dönüşü Tamamla
                else if (!hasReturnArrival)
                  CompleteReturnButton(
                    onPressed: _handleCompleteReturn,
                    isEnabled: true,
                    isLoading: _isCompletingReturn,
                  ),
                // hasReturnArrival = true ise hiçbir buton gösterme (gün tamamlandı)
              ],

              const SizedBox(height: 24),

              // Bugünkü durum kartı (demo)
              if (demoRecord != null)
                TodayStatusCardWidget(todayRecord: demoRecord, isDemo: true),

              // Durum mesajı (sadece yol hesaplama kapalıysa)
              if (!commuteTrackingEnabled)
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
