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
  bool _isStartingCommute = false;
  bool _isCompletingReturn = false;

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

  Future<void> _handleStartCommute() async {
    if (_isStartingCommute) return;

    setState(() {
      _isStartingCommute = true;
    });

    try {
      final startCommuteAction = ref.read(startCommuteActionProvider);

      // Sadece yola çıkışı kaydet
      await startCommuteAction();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yola çıkış kaydedildi!'),
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
          _isStartingCommute = false;
        });
      }
    }
  }

  Future<void> _handleCompleteReturn() async {
    if (_isCompletingReturn) return;

    setState(() {
      _isCompletingReturn = true;
    });

    try {
      final completeReturnAction = ref.read(completeReturnActionProvider);
      await completeReturnAction();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dönüş tamamlandı!'),
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
          _isCompletingReturn = false;
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
    final commuteTrackingEnabled = ref.watch(commuteTrackingEnabledProvider);

    final bool hasCommuteDeparture = todayRecord?.commuteDepartureTime != null;
    final bool hasCheckedIn = todayRecord?.checkInTime != null;
    final bool hasCheckedOut = todayRecord?.checkOutTime != null;
    final bool hasReturnArrival = todayRecord?.returnArrivalTime != null;

    // Bugün için herhangi bir aksiyon alınmış mı kontrol et
    final bool hasTodayAction =
        todayRecord != null &&
        (todayRecord.commuteDepartureTime != null ||
            todayRecord.checkInTime != null ||
            todayRecord.checkOutTime != null ||
            todayRecord.returnArrivalTime != null);

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

              // Bugünkü durum kartı
              if (todayRecord != null) TodayStatusCardWidget(todayRecord: todayRecord),

              // Durum mesajı (sadece yol hesaplama kapalıysa)
              if (!commuteTrackingEnabled)
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
