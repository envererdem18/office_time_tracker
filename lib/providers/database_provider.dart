import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/check_in_out.dart';
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

// Tarih filtresi için state provider
final dateFilterProvider = StateProvider<DateRange?>((ref) => null);

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

// İstatistikler için provider
final statisticsProvider = Provider<Statistics>((ref) {
  final records = ref.watch(filteredCheckInOutListProvider);
  return Statistics.fromRecords(records);
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

  Statistics({
    required this.averageWorkHours,
    required this.totalWorkHours,
    required this.totalWorkDays,
    required this.workHoursDistribution,
    required this.dailyStats,
  });

  factory Statistics.fromRecords(List<CheckInOut> records) {
    final validRecords = records.where((r) => r.workDuration != null).toList();

    if (validRecords.isEmpty) {
      return Statistics(
        averageWorkHours: 0,
        totalWorkHours: 0,
        totalWorkDays: 0,
        workHoursDistribution: {},
        dailyStats: [],
      );
    }

    double totalHours = 0;
    Map<String, int> distribution = {'<8 saat': 0, '8-9 saat': 0, '>9 saat': 0};

    List<DailyStats> dailyStats = [];

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
      dailyStats.add(
        DailyStats(
          date: record.date,
          workHours: hours,
          checkInHour: record.checkInTime?.hour.toDouble() ?? 0,
        ),
      );
    }

    return Statistics(
      averageWorkHours: totalHours / validRecords.length,
      totalWorkHours: totalHours,
      totalWorkDays: validRecords.length,
      workHoursDistribution: distribution,
      dailyStats: dailyStats,
    );
  }
}

// Günlük istatistik sınıfı
class DailyStats {
  final DateTime date;
  final double workHours;
  final double checkInHour;

  DailyStats({required this.date, required this.workHours, required this.checkInHour});
}
