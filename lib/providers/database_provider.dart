import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../models/check_in_out.dart';
import '../models/working_hours.dart';
import '../services/database_service.dart';

// DatabaseService provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Tüm kayıtları getiren provider
final checkInOutListProvider = FutureProvider<List<CheckInOut>>((ref) async {
  final databaseService = ref.read(databaseServiceProvider);
  return databaseService.getAllCheckInOuts();
});

// Database değişikliklerini takip etmek için state provider
final _databaseChangeNotifierProvider = StateProvider<int>((ref) => 0);

// Bugünkü kaydı getiren provider
final todayCheckInOutProvider = Provider<CheckInOut?>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  // Database değişiklik notifier'ını watch et
  ref.watch(_databaseChangeNotifierProvider);
  return databaseService.getTodayCheckInOut();
});

// Filtre state modeli
class FilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isMonthMode;
  final Set<int> selectedMonths;

  FilterState({
    this.startDate,
    this.endDate,
    this.isMonthMode = false,
    this.selectedMonths = const {},
  });

  FilterState copyWith({
    DateTime? Function()? startDate,
    DateTime? Function()? endDate,
    bool? isMonthMode,
    Set<int>? selectedMonths,
  }) {
    return FilterState(
      startDate: startDate != null ? startDate() : this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
      isMonthMode: isMonthMode ?? this.isMonthMode,
      selectedMonths: selectedMonths ?? this.selectedMonths,
    );
  }

  FilterState clear() {
    // Clear = Başlangıç durumuna dön (şu anki ay)
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return FilterState(
      startDate: startOfMonth,
      endDate: endOfMonth,
      isMonthMode: true,
      selectedMonths: {now.month},
    );
  }

  FilterState clearToAllTime() {
    // Tüm zamanları göster
    return FilterState(
      startDate: null,
      endDate: null,
      isMonthMode: false,
      selectedMonths: {},
    );
  }

  bool get hasFilter => startDate != null && endDate != null;

  DateRange? get dateRange {
    if (startDate != null && endDate != null) {
      return DateRange(startDate: startDate!, endDate: endDate!);
    }
    return null;
  }
}

// Global filtre state provider - Default olarak içinde bulunulan ay
final filterStateProvider = StateProvider<FilterState>((ref) {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);

  return FilterState(
    startDate: startOfMonth,
    endDate: endOfMonth,
    isMonthMode: true,
    selectedMonths: {now.month},
  );
});

// Tarih filtresi için state provider (geriye dönük uyumluluk için)
final dateFilterProvider = Provider<DateRange?>((ref) {
  final filterState = ref.watch(filterStateProvider);
  return filterState.dateRange;
});

// Filtrelenmiş kayıtları getiren provider
final filteredCheckInOutListProvider = Provider<List<CheckInOut>>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  final dateFilter = ref.watch(dateFilterProvider);

  if (dateFilter != null) {
    return databaseService.getCheckInOutsByDateRange(
      dateFilter.startDate,
      dateFilter.endDate,
    );
  }

  return databaseService.getAllCheckInOuts();
});

// Giriş yapma action provider
final checkInActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.checkInToday();
    // Database değişiklik notifier'ını güncelle
    ref.read(_databaseChangeNotifierProvider.notifier).state++;
    ref.invalidate(checkInOutListProvider);
    ref.invalidate(filteredCheckInOutListProvider);
  };
});

// Çıkış yapma action provider
final checkOutActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.checkOutToday();
    // Database değişiklik notifier'ını güncelle
    ref.read(_databaseChangeNotifierProvider.notifier).state++;
    ref.invalidate(checkInOutListProvider);
    ref.invalidate(filteredCheckInOutListProvider);
  };
});

// Kayıt silme action provider
final deleteRecordActionProvider = Provider<Future<void> Function(DateTime)>((ref) {
  return (DateTime date) async {
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.deleteCheckInOut(date);
    // Database değişiklik notifier'ını güncelle
    ref.read(_databaseChangeNotifierProvider.notifier).state++;
    ref.invalidate(checkInOutListProvider);
    ref.invalidate(filteredCheckInOutListProvider);
  };
});

// Kayıt güncelleme action provider
final updateRecordActionProvider = Provider<Future<void> Function(CheckInOut)>((ref) {
  return (CheckInOut record) async {
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.updateCheckInOut(record);
    // Database değişiklik notifier'ını güncelle
    ref.read(_databaseChangeNotifierProvider.notifier).state++;
    ref.invalidate(checkInOutListProvider);
    ref.invalidate(filteredCheckInOutListProvider);
  };
});

// Working hours provider
final workingHoursProvider = Provider<Map<int, WorkingHours>>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  // Database değişiklik notifier'ını watch et
  ref.watch(_databaseChangeNotifierProvider);
  return databaseService.getAllWorkingHours();
});

// Settings provider
final settingsProvider = Provider<AppSettings>((ref) {
  final databaseService = ref.read(databaseServiceProvider);
  // Database değişiklik notifier'ını watch et
  ref.watch(_databaseChangeNotifierProvider);
  return databaseService.getSettings();
});

// Yol hesaplama ayarı provider - Basit StateProvider
final commuteTrackingEnabledProvider = StateProvider<bool>((ref) {
  // İlk değeri database'den al
  final databaseService = ref.read(databaseServiceProvider);
  return databaseService.getSettings().enableCommuteTracking;
});

// Yol hesaplama ayarını güncelleme action provider
final updateCommuteTrackingActionProvider = Provider<Future<void> Function(bool)>((ref) {
  return (bool enabled) async {
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.updateCommuteTracking(enabled);

    // StateProvider'ı direkt güncelle
    ref.read(commuteTrackingEnabledProvider.notifier).state = enabled;
  };
});

// Yola çıkma action provider
final startCommuteActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.startCommute();
    // Database değişiklik notifier'ını güncelle
    ref.read(_databaseChangeNotifierProvider.notifier).state++;
    ref.invalidate(checkInOutListProvider);
    ref.invalidate(filteredCheckInOutListProvider);
  };
});

// Dönüşü tamamlama action provider
final completeReturnActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final databaseService = ref.read(databaseServiceProvider);
    await databaseService.completeReturn();
    // Database değişiklik notifier'ını güncelle
    ref.read(_databaseChangeNotifierProvider.notifier).state++;
    ref.invalidate(checkInOutListProvider);
    ref.invalidate(filteredCheckInOutListProvider);
  };
});

// İstatistikler için provider
final statisticsProvider = Provider<Statistics>((ref) {
  final records = ref.watch(filteredCheckInOutListProvider);
  final workingHours = ref.watch(workingHoursProvider);
  return Statistics.fromRecords(records, workingHours);
});

// Tarih aralığı sınıfı
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});
}

// İstatistik sınıfı
class Statistics {
  final double averageWorkHours;
  final double totalWorkHours;
  final int totalWorkDays;
  final Map<String, int> workHoursDistribution;
  final List<DailyStats> dailyStats;
  // Yeni metrikler
  final int lateCheckIns;
  final double averageLateMinutes;
  final double totalOvertimeMinutes;
  final int overtimeDays;
  // Yol metrikleri
  final double averageOutboundCommuteMinutes;
  final double averageReturnCommuteMinutes;
  final double averageTotalCommuteMinutes;
  final int daysWithCommute;

  Statistics({
    required this.averageWorkHours,
    required this.totalWorkHours,
    required this.totalWorkDays,
    required this.workHoursDistribution,
    required this.dailyStats,
    required this.lateCheckIns,
    required this.averageLateMinutes,
    required this.totalOvertimeMinutes,
    required this.overtimeDays,
    required this.averageOutboundCommuteMinutes,
    required this.averageReturnCommuteMinutes,
    required this.averageTotalCommuteMinutes,
    required this.daysWithCommute,
  });

  factory Statistics.fromRecords(
    List<CheckInOut> records,
    Map<int, WorkingHours> workingHoursMap,
  ) {
    final validRecords = records.where((r) => r.workDuration != null).toList();

    if (validRecords.isEmpty) {
      return Statistics(
        averageWorkHours: 0,
        totalWorkHours: 0,
        totalWorkDays: 0,
        workHoursDistribution: {},
        dailyStats: [],
        lateCheckIns: 0,
        averageLateMinutes: 0,
        totalOvertimeMinutes: 0,
        overtimeDays: 0,
        averageOutboundCommuteMinutes: 0,
        averageReturnCommuteMinutes: 0,
        averageTotalCommuteMinutes: 0,
        daysWithCommute: 0,
      );
    }

    double totalHours = 0;
    Map<String, int> distribution = {'<8 saat': 0, '8-9 saat': 0, '>9 saat': 0};

    List<DailyStats> dailyStats = [];

    // Yeni metrik hesaplamaları
    int lateCheckIns = 0;
    double totalLateMinutes = 0;
    double totalOvertimeMinutes = 0;
    int overtimeDays = 0;

    // Yol metrikleri
    double totalOutboundCommuteMinutes = 0;
    double totalReturnCommuteMinutes = 0;
    double totalTotalCommuteMinutes = 0;
    int daysWithCommute = 0;

    for (final record in validRecords) {
      final hours = record.workDuration!.inMinutes / 60.0;
      totalHours += hours;

      // Dağılım hesaplama
      if (hours < 8) {
        distribution['<8 saat'] = distribution['<8 saat']! + 1;
      } else if (hours >= 8 && hours <= 9) {
        distribution['8-9 saat'] = distribution['8-9 saat']! + 1;
      } else {
        distribution['>9 saat'] = distribution['>9 saat']! + 1;
      }

      // Günlük istatistik
      // Giriş saatini ondalık formatta hesapla (örn: 9:30 = 9.5)
      final checkInHourDecimal = record.checkInTime != null
          ? record.checkInTime!.hour + (record.checkInTime!.minute / 60.0)
          : 0.0;

      // Mesai saatlerine göre geç kalma ve fazla mesai hesaplama
      final weekday = record.date.weekday;
      final workingHours = workingHoursMap[weekday];

      double? lateMinutes;
      double? overtimeMinutes;

      if (workingHours != null && workingHours.hasWorkingHours) {
        // Geç kalma hesabı
        if (record.checkInTime != null) {
          final checkInMinutes =
              record.checkInTime!.hour * 60 + record.checkInTime!.minute;
          final expectedStartMinutes =
              workingHours.startTime!.hour * 60 + workingHours.startTime!.minute;

          if (checkInMinutes > expectedStartMinutes) {
            lateMinutes = (checkInMinutes - expectedStartMinutes).toDouble();
            lateCheckIns++;
            totalLateMinutes += lateMinutes;
          }
        }

        // Fazla mesai hesabı - Toplam çalışma saatine göre (dakika cinsinden)
        if (record.workDuration != null) {
          // Mesai başlangıç ve bitiş saatlerinden beklenen çalışma süresini hesapla
          final expectedStartMinutes =
              workingHours.startTime!.hour * 60 + workingHours.startTime!.minute;
          final expectedEndMinutes =
              workingHours.endTime!.hour * 60 + workingHours.endTime!.minute;
          final expectedWorkMinutes = expectedEndMinutes - expectedStartMinutes;

          // Gerçek çalışma dakikası
          final actualWorkMinutes = record.workDuration!.inMinutes.toDouble();

          // Gerçek çalışma dakikası > beklenen çalışma dakikası ise fazla mesai var
          if (actualWorkMinutes > expectedWorkMinutes) {
            overtimeMinutes = actualWorkMinutes - expectedWorkMinutes;
            totalOvertimeMinutes += overtimeMinutes;
            overtimeDays++;
          }
        }
      }

      // Yol sürelerini hesapla
      double? outboundCommuteMinutes;
      double? returnCommuteMinutes;
      double? totalCommuteMinutes;

      if (record.outboundCommuteDuration != null) {
        outboundCommuteMinutes = record.outboundCommuteDuration!.inMinutes.toDouble();
        totalOutboundCommuteMinutes += outboundCommuteMinutes;
      }

      if (record.returnCommuteDuration != null) {
        returnCommuteMinutes = record.returnCommuteDuration!.inMinutes.toDouble();
        totalReturnCommuteMinutes += returnCommuteMinutes;
      }

      if (record.totalCommuteDuration != null) {
        totalCommuteMinutes = record.totalCommuteDuration!.inMinutes.toDouble();
        totalTotalCommuteMinutes += totalCommuteMinutes;
        daysWithCommute++;
      }

      dailyStats.add(
        DailyStats(
          date: record.date,
          workHours: hours,
          checkInHour: checkInHourDecimal,
          lateMinutes: lateMinutes,
          overtimeMinutes: overtimeMinutes,
          outboundCommuteMinutes: outboundCommuteMinutes,
          returnCommuteMinutes: returnCommuteMinutes,
          totalCommuteMinutes: totalCommuteMinutes,
        ),
      );
    }

    return Statistics(
      averageWorkHours: totalHours / validRecords.length,
      totalWorkHours: totalHours,
      totalWorkDays: validRecords.length,
      workHoursDistribution: distribution,
      dailyStats: dailyStats,
      lateCheckIns: lateCheckIns,
      averageLateMinutes: lateCheckIns > 0 ? totalLateMinutes / lateCheckIns : 0,
      totalOvertimeMinutes: totalOvertimeMinutes,
      overtimeDays: overtimeDays,
      averageOutboundCommuteMinutes: daysWithCommute > 0
          ? totalOutboundCommuteMinutes / daysWithCommute
          : 0,
      averageReturnCommuteMinutes: daysWithCommute > 0
          ? totalReturnCommuteMinutes / daysWithCommute
          : 0,
      averageTotalCommuteMinutes: daysWithCommute > 0
          ? totalTotalCommuteMinutes / daysWithCommute
          : 0,
      daysWithCommute: daysWithCommute,
    );
  }
}

// Günlük istatistik sınıfı
class DailyStats {
  final DateTime date;
  final double workHours;
  final double checkInHour;
  final double? lateMinutes;
  final double? overtimeMinutes;
  final double? outboundCommuteMinutes;
  final double? returnCommuteMinutes;
  final double? totalCommuteMinutes;

  DailyStats({
    required this.date,
    required this.workHours,
    required this.checkInHour,
    this.lateMinutes,
    this.overtimeMinutes,
    this.outboundCommuteMinutes,
    this.returnCommuteMinutes,
    this.totalCommuteMinutes,
  });
}
