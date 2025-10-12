import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/check_in_out.dart';
import '../models/working_hours.dart';

class DatabaseService {
  static const String _boxName = 'checkInOutBox';
  static const String _workingHoursBoxName = 'workingHoursBox';
  late Box<CheckInOut> _box;
  late Box<WorkingHours> _workingHoursBox;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Hive box'ını başlat
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CheckInOutAdapter());
    Hive.registerAdapter(WorkingHoursAdapter());
    Hive.registerAdapter(TimeOfDayAdapter());
    _box = await Hive.openBox<CheckInOut>(_boxName);
    _workingHoursBox = await Hive.openBox<WorkingHours>(_workingHoursBoxName);

    // Sadece ilk kez çalıştırıldığında eski integer key'leri temizle
    await _migrateOldKeysIfNeeded();
  }

  // Eski integer key'leri kontrol et ve gerekirse migrate et
  Future<void> _migrateOldKeysIfNeeded() async {
    final keys = _box.keys.toList();
    bool hasIntegerKeys = false;

    // Integer key var mı kontrol et
    for (final key in keys) {
      if (key is int) {
        hasIntegerKeys = true;
        break;
      }
    }

    // Eğer integer key'ler varsa migrate et
    if (hasIntegerKeys) {
      final recordsToMigrate = <CheckInOut>[];
      final keysToDelete = <dynamic>[];

      for (final key in keys) {
        if (key is int) {
          final record = _box.get(key);
          if (record != null) {
            recordsToMigrate.add(record);
            keysToDelete.add(key);
          }
        }
      }

      // Eski kayıtları sil
      for (final key in keysToDelete) {
        await _box.delete(key);
      }

      // Yeni key formatı ile kayıtları ekle
      for (final record in recordsToMigrate) {
        final newKey = _getDateKey(record.date);
        await _box.put(newKey, record);
      }
    }
  }

  // Yeni kayıt ekle
  Future<void> addCheckInOut(CheckInOut checkInOut) async {
    final key = _getDateKey(checkInOut.date);
    await _box.put(key, checkInOut);
  }

  // Tarih için key oluştur (YYYYMMDD formatında)
  String _getDateKey(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  // Tüm kayıtları getir
  List<CheckInOut> getAllCheckInOuts() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // En yeni tarih en üstte
  }

  // Belirli tarih aralığındaki kayıtları getir
  List<CheckInOut> getCheckInOutsByDateRange(DateTime startDate, DateTime endDate) {
    return _box.values
        .where(
          (checkInOut) =>
              checkInOut.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              checkInOut.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Bugünkü kaydı getir
  CheckInOut? getTodayCheckInOut() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final todayKey = _getDateKey(todayDate);
    return _box.get(todayKey);
  }

  // Belirli bir tarihteki kaydı getir
  CheckInOut? getCheckInOutByDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateKey = _getDateKey(normalizedDate);
    return _box.get(dateKey);
  }

  // Kaydı güncelle
  Future<void> updateCheckInOut(CheckInOut checkInOut) async {
    final key = _getDateKey(checkInOut.date);
    await _box.put(key, checkInOut);
  }

  // Kaydı sil
  Future<void> deleteCheckInOut(DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dateKey = _getDateKey(normalizedDate);
    await _box.delete(dateKey);
  }

  // Bugün için giriş yap
  Future<void> checkInToday() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    CheckInOut? existingRecord = getTodayCheckInOut();

    if (existingRecord == null) {
      // Yeni kayıt oluştur
      final newRecord = CheckInOut(date: todayDate, checkInTime: today);
      await addCheckInOut(newRecord);
      debugPrint('✅ Yeni giriş kaydı oluşturuldu: ${_getDateKey(todayDate)}');
    } else {
      // Mevcut kaydı güncelle
      existingRecord.checkInTime = today;
      await updateCheckInOut(existingRecord);
      debugPrint('✅ Mevcut kayıt güncellendi: ${_getDateKey(todayDate)}');
    }

    debugBoxStatus();
  }

  // Bugün için çıkış yap
  Future<void> checkOutToday() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    CheckInOut? existingRecord = getTodayCheckInOut();

    if (existingRecord != null) {
      existingRecord.checkOutTime = today;
      await updateCheckInOut(existingRecord);
      debugPrint('✅ Çıkış kaydı güncellendi: ${_getDateKey(todayDate)}');
    } else {
      // Eğer giriş kaydı yoksa, sadece çıkış kaydı oluştur
      final newRecord = CheckInOut(date: todayDate, checkOutTime: today);
      await addCheckInOut(newRecord);
      debugPrint('✅ Yeni çıkış kaydı oluşturuldu: ${_getDateKey(todayDate)}');
    }

    debugBoxStatus();
  }

  // Box'ı kapat
  Future<void> close() async {
    await _box.close();
  }

  // Debug: Box durumunu kontrol et
  void debugBoxStatus() {
    debugPrint('=== HIVE BOX DEBUG ===');
    debugPrint('Box isOpen: ${_box.isOpen}');
    debugPrint('Box length: ${_box.length}');
    debugPrint('Box keys: ${_box.keys.toList()}');
    debugPrint(
      'Box values: ${_box.values.map((e) => '${e.date} - ${e.checkInTime} - ${e.checkOutTime}').toList()}',
    );
    debugPrint('=====================');
  }

  // ============ Working Hours CRUD ============

  // Belirli bir gün için mesai saatlerini getir
  WorkingHours? getWorkingHoursByWeekday(int weekday) {
    return _workingHoursBox.get(weekday);
  }

  // Tüm mesai saatlerini getir
  Map<int, WorkingHours> getAllWorkingHours() {
    final Map<int, WorkingHours> workingHoursMap = {};
    for (var i = 1; i <= 7; i++) {
      final workingHours = _workingHoursBox.get(i);
      if (workingHours != null) {
        workingHoursMap[i] = workingHours;
      }
    }
    return workingHoursMap;
  }

  // Mesai saatlerini güncelle veya oluştur
  Future<void> saveWorkingHours(WorkingHours workingHours) async {
    await _workingHoursBox.put(workingHours.weekday, workingHours);
  }

  // Belirli bir gün için mesai saatlerini sil
  Future<void> deleteWorkingHours(int weekday) async {
    await _workingHoursBox.delete(weekday);
  }

  // Tüm mesai saatlerini toplu kaydet
  Future<void> saveAllWorkingHours(Map<int, WorkingHours> workingHoursMap) async {
    for (var entry in workingHoursMap.entries) {
      await _workingHoursBox.put(entry.key, entry.value);
    }
  }
}
