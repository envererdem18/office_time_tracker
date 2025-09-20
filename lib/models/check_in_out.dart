import 'package:hive/hive.dart';

part 'check_in_out.g.dart';

@HiveType(typeId: 0)
class CheckInOut extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  DateTime? checkInTime;

  @HiveField(2)
  DateTime? checkOutTime;

  CheckInOut({required this.date, this.checkInTime, this.checkOutTime});

  // Ofiste geçirilen süreyi hesaplayan getter
  Duration? get workDuration {
    if (checkInTime != null && checkOutTime != null) {
      return checkOutTime!.difference(checkInTime!);
    }
    return null;
  }

  // Günün string formatında gösterimi
  String get dateString {
    final weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];

    return '${date.day} $month ${date.year}, $weekday';
  }

  // Giriş saatinin string formatı
  String get checkInTimeString {
    if (checkInTime != null) {
      return '${checkInTime!.hour.toString().padLeft(2, '0')}:${checkInTime!.minute.toString().padLeft(2, '0')}';
    }
    return '--:--';
  }

  // Çıkış saatinin string formatı
  String get checkOutTimeString {
    if (checkOutTime != null) {
      return '${checkOutTime!.hour.toString().padLeft(2, '0')}:${checkOutTime!.minute.toString().padLeft(2, '0')}';
    }
    return '--:--';
  }

  // Çalışma süresinin string formatı
  String get workDurationString {
    if (workDuration != null) {
      final hours = workDuration!.inHours;
      final minutes = workDuration!.inMinutes.remainder(60);
      return '$hours saat $minutes dakika';
    }
    return '--';
  }
}
