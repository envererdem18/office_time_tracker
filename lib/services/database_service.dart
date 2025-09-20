import 'package:hive_flutter/hive_flutter.dart';

import '../models/check_in_out.dart';

class DatabaseService {
  static const String _boxName = 'checkInOutBox';
  late Box<CheckInOut> _box;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Hive box'ını başlat
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(CheckInOutAdapter());
    _box = await Hive.openBox<CheckInOut>(_boxName);

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
      print('✅ Yeni giriş kaydı oluşturuldu: ${_getDateKey(todayDate)}');
    } else {
      // Mevcut kaydı güncelle
      existingRecord.checkInTime = today;
      await updateCheckInOut(existingRecord);
      print('✅ Mevcut kayıt güncellendi: ${_getDateKey(todayDate)}');
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
      print('✅ Çıkış kaydı güncellendi: ${_getDateKey(todayDate)}');
    } else {
      // Eğer giriş kaydı yoksa, sadece çıkış kaydı oluştur
      final newRecord = CheckInOut(date: todayDate, checkOutTime: today);
      await addCheckInOut(newRecord);
      print('✅ Yeni çıkış kaydı oluşturuldu: ${_getDateKey(todayDate)}');
    }

    debugBoxStatus();
  }

  // Box'ı kapat
  Future<void> close() async {
    await _box.close();
  }

  // Debug: Box durumunu kontrol et
  void debugBoxStatus() {
    print('=== HIVE BOX DEBUG ===');
    print('Box isOpen: ${_box.isOpen}');
    print('Box length: ${_box.length}');
    print('Box keys: ${_box.keys.toList()}');
    print(
      'Box values: ${_box.values.map((e) => '${e.date} - ${e.checkInTime} - ${e.checkOutTime}').toList()}',
    );
    print('=====================');
  }
}
