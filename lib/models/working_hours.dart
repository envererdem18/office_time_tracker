import 'package:flutter/material.dart' as flutter;
import 'package:hive/hive.dart';

part 'working_hours.g.dart';

@HiveType(typeId: 1)
class WorkingHours extends HiveObject {
  @HiveField(0)
  int weekday; // 1=Pazartesi, 7=Pazar

  @HiveField(1)
  TimeOfDay? startTime;

  @HiveField(2)
  TimeOfDay? endTime;

  WorkingHours({required this.weekday, this.startTime, this.endTime});

  String get weekdayName {
    const weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return weekdays[weekday - 1];
  }

  String get startTimeString {
    if (startTime != null) {
      return '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';
    }
    return 'Yok';
  }

  String get endTimeString {
    if (endTime != null) {
      return '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
    }
    return 'Yok';
  }

  bool get hasWorkingHours => startTime != null && endTime != null;
}

// TimeOfDay için Hive adapter
@HiveType(typeId: 2)
class TimeOfDay {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  // Flutter TimeOfDay'den dönüşüm
  factory TimeOfDay.fromFlutter(flutter.TimeOfDay time) {
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  // Flutter TimeOfDay'e dönüşüm
  flutter.TimeOfDay toFlutter() {
    return flutter.TimeOfDay(hour: hour, minute: minute);
  }

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
