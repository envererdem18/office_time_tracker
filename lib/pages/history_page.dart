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
import '../widgets/organisms/history_summary_widget.dart';
import '../widgets/organisms/records_list_widget.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _lastUsedMonthMode = false;
  Set<int> _lastSelectedMonths = {};

  @override
  void initState() {
    super.initState();
    _startDate = null;
    _endDate = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dateFilterProvider.notifier).state = null;
    });
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      // Görünüm türünü koruyarak sadece seçimleri temizle
      _lastSelectedMonths.clear();
      // _lastUsedMonthMode değiştirme - mevcut görünümde kal
    });
    ref.read(dateFilterProvider.notifier).state = null;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        initialStartDate: _startDate,
        initialEndDate: _endDate,
        initialMonthMode: _lastUsedMonthMode,
        initialSelectedMonths: _lastSelectedMonths,
        onDateRangeChanged: (start, end) {
          setState(() {
            _startDate = start;
            _endDate = end;
          });
          if (start != null && end != null) {
            ref.read(dateFilterProvider.notifier).state = DateRange(
              startDate: start,
              endDate: end,
            );
          } else {
            ref.read(dateFilterProvider.notifier).state = null;
          }
        },
        onStateChanged: (isMonthMode, selectedMonths) {
          setState(() {
            _lastUsedMonthMode = isMonthMode;
            _lastSelectedMonths = selectedMonths;
          });
        },
        onClear: _clearFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = ref.watch(filteredCheckInOutListProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Geçmiş Kayıtlar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              (_startDate != null && _endDate != null) ? Icons.filter_alt : Icons.tune,
              color: (_startDate != null && _endDate != null)
                  ? AppTheme.primaryColor
                  : null,
            ),
            onPressed: _showFilterBottomSheet,
            tooltip: (_startDate != null && _endDate != null)
                ? 'Filtre Aktif'
                : 'Filtrele',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // İstatistik özeti
            HistorySummaryWidget(records: filteredRecords),

            // Kayıt listesi
            RecordsListWidget(
              records: filteredRecords,
              onTap: _showRecordDetails,
              onEdit: _editRecord,
              onDelete: _deleteRecord,
            ),
          ],
        ),
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
