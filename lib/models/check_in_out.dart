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

  @HiveField(3)
  DateTime? commuteDepartureTime; // Yola çıkış zamanı

  @HiveField(4)
  DateTime? returnArrivalTime; // Dönüş tamamlanma zamanı

  CheckInOut({
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.commuteDepartureTime,
    this.returnArrivalTime,
  });

  // Ofiste geçirilen süreyi hesaplayan getter
  Duration? get workDuration {
    if (checkInTime != null && checkOutTime != null) {
      return checkOutTime!.difference(checkInTime!);
    }
    return null;
  }

  // Gidiş yolu süresi (commuteDepartureTime -> checkInTime)
  Duration? get outboundCommuteDuration {
    if (commuteDepartureTime != null && checkInTime != null) {
      return checkInTime!.difference(commuteDepartureTime!);
    }
    return null;
  }

  // Dönüş yolu süresi (checkOutTime -> returnArrivalTime)
  Duration? get returnCommuteDuration {
    if (checkOutTime != null && returnArrivalTime != null) {
      return returnArrivalTime!.difference(checkOutTime!);
    }
    return null;
  }

  // Toplam yol süresi
  Duration? get totalCommuteDuration {
    if (outboundCommuteDuration != null && returnCommuteDuration != null) {
      return outboundCommuteDuration! + returnCommuteDuration!;
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

  // Yola çıkış zamanının string formatı
  String get commuteDepartureTimeString {
    if (commuteDepartureTime != null) {
      return '${commuteDepartureTime!.hour.toString().padLeft(2, '0')}:${commuteDepartureTime!.minute.toString().padLeft(2, '0')}';
    }
    return '--:--';
  }

  // Dönüş tamamlanma zamanının string formatı
  String get returnArrivalTimeString {
    if (returnArrivalTime != null) {
      return '${returnArrivalTime!.hour.toString().padLeft(2, '0')}:${returnArrivalTime!.minute.toString().padLeft(2, '0')}';
    }
    return '--:--';
  }

  // Gidiş yolu süresinin string formatı
  String get outboundCommuteDurationString {
    if (outboundCommuteDuration != null) {
      final hours = outboundCommuteDuration!.inHours;
      final minutes = outboundCommuteDuration!.inMinutes.remainder(60);
      return '$hours saat $minutes dakika';
    }
    return '--';
  }

  // Dönüş yolu süresinin string formatı
  String get returnCommuteDurationString {
    if (returnCommuteDuration != null) {
      final hours = returnCommuteDuration!.inHours;
      final minutes = returnCommuteDuration!.inMinutes.remainder(60);
      return '$hours saat $minutes dakika';
    }
    return '--';
  }

  // Toplam yol süresinin string formatı
  String get totalCommuteDurationString {
    if (totalCommuteDuration != null) {
      final hours = totalCommuteDuration!.inHours;
      final minutes = totalCommuteDuration!.inMinutes.remainder(60);
      return '$hours saat $minutes dakika';
    }
    return '--';
  }
}
