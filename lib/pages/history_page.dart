import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/check_in_out.dart';
import '../providers/database_provider.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/molecules/delete_confirm_dialog.dart';
import '../widgets/molecules/record_details_dialog.dart';
import '../widgets/organisms/filter_bottom_sheet_widget.dart';
import '../widgets/organisms/records_list_widget.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  void _clearFilter() {
    ref.read(filterStateProvider.notifier).state = ref.read(filterStateProvider).clear();
  }

  void _showFilterBottomSheet() {
    final currentFilter = ref.read(filterStateProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        initialStartDate: currentFilter.startDate,
        initialEndDate: currentFilter.endDate,
        initialMonthMode: currentFilter.isMonthMode,
        initialSelectedMonths: currentFilter.selectedMonths,
        onDateRangeChanged: (start, end) {
          ref.read(filterStateProvider.notifier).state = ref
              .read(filterStateProvider)
              .copyWith(startDate: () => start, endDate: () => end);
        },
        onStateChanged: (isMonthMode, selectedMonths) {
          ref.read(filterStateProvider.notifier).state = ref
              .read(filterStateProvider)
              .copyWith(isMonthMode: isMonthMode, selectedMonths: selectedMonths);
        },
        onClear: _clearFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = ref.watch(filteredCheckInOutListProvider);
    final filterState = ref.watch(filterStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Geçmiş Kayıtlar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: kDebugMode
            ? IconButton(
                icon: const Icon(Icons.bug_report, color: Colors.orange),
                onPressed: _showGenerateTestDataConfirmation,
                tooltip: 'Test Verisi Oluştur',
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(
              filterState.hasFilter ? Icons.filter_alt : Icons.tune,
              color: filterState.hasFilter ? AppTheme.primaryColor : null,
            ),
            onPressed: _showFilterBottomSheet,
            tooltip: filterState.hasFilter ? 'Filtre Aktif' : 'Filtrele',
          ),
        ],
      ),
      body: RecordsListWidget(
        records: filteredRecords,
        onTap: _showRecordDetails,
        onEdit: _editRecord,
        onDelete: _deleteRecord,
        itemsPerPage: 20,
      ),
    );
  }

  void _showRecordDetails(CheckInOut record) {
    showDialog(
      context: context,
      builder: (context) => RecordDetailsDialog(record: record),
    );
  }

  Future<void> _editRecord(CheckInOut record) async {
    context.pushNamed(AppRoute.edit.name, extra: record);
  }

  void _showGenerateTestDataConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Test Verisi Oluştur',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tüm mevcut kayıtlar silinecek ve son 30 iş günü için test verisi oluşturulacak.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.textSecondaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'İptal',
                      style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _generateTestData();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Oluştur',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateTestData() async {
    final dbService = ref.read(databaseServiceProvider);
    final random = Random();

    try {
      // 1. Tüm eski kayıtları sil
      final allRecords = dbService.getAllCheckInOuts();
      for (final record in allRecords) {
        await dbService.deleteCheckInOut(record.date);
      }

      // 2. Son 30 iş gününü oluştur
      final now = DateTime.now();
      int businessDaysCreated = 0;
      int daysBack = 0;

      while (businessDaysCreated < 30) {
        daysBack++;
        final targetDate = now.subtract(Duration(days: daysBack));

        // Hafta sonu değilse (Cumartesi: 6, Pazar: 7)
        if (targetDate.weekday != DateTime.saturday &&
            targetDate.weekday != DateTime.sunday) {
          // Sadece tarih kısmını al (saat bilgisi olmadan)
          final dateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);

          // Giriş saati: 08:00 - 10:00 arası random
          final checkInHour = 8 + random.nextInt(3); // 8, 9, veya 10
          final checkInMinute = random.nextInt(60); // 0-59
          final checkInTime = DateTime(
            dateOnly.year,
            dateOnly.month,
            dateOnly.day,
            checkInHour,
            checkInMinute,
          );

          // Çıkış saati: 17:00 - 20:00 arası random
          final checkOutHour = 17 + random.nextInt(4); // 17, 18, 19, veya 20
          final checkOutMinute = random.nextInt(60); // 0-59
          final checkOutTime = DateTime(
            dateOnly.year,
            dateOnly.month,
            dateOnly.day,
            checkOutHour,
            checkOutMinute,
          );

          // Yola çıkış zamanı: Giriş saatinden 20-60 dakika önce
          final outboundCommuteMinutes = 20 + random.nextInt(41); // 20-60 dakika
          final commuteDepartureTime = checkInTime.subtract(
            Duration(minutes: outboundCommuteMinutes),
          );

          // Eve varış zamanı: Çıkış saatinden 20-60 dakika sonra
          final returnCommuteMinutes = 20 + random.nextInt(41); // 20-60 dakika
          final returnArrivalTime = checkOutTime.add(
            Duration(minutes: returnCommuteMinutes),
          );

          // Yeni kayıt oluştur
          final newRecord = CheckInOut(
            date: dateOnly,
            checkInTime: checkInTime,
            checkOutTime: checkOutTime,
            commuteDepartureTime: commuteDepartureTime,
            returnArrivalTime: returnArrivalTime,
          );

          await dbService.addCheckInOut(newRecord);
          businessDaysCreated++;
        }
      }

      // Verileri yenile
      ref.invalidate(filteredCheckInOutListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 30 iş günü test verisi oluşturuldu!'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Hata: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  Future<void> _deleteRecord(CheckInOut record) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        record: record,
        onConfirm: () async {
          try {
            final deleteAction = ref.read(deleteRecordActionProvider);
            await deleteAction(record.date);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kayıt başarıyla silindi!'),
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
          }
        },
      ),
    );
  }
}
