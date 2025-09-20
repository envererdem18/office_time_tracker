import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/check_in_out.dart';
import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_card.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Varsayılan olarak son 30 günü göster
    final now = DateTime.now();
    _endDate = DateTime(now.year, now.month, now.day);
    _startDate = _endDate!.subtract(const Duration(days: 30));

    // Provider'ı güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dateFilterProvider.notifier).state = DateRange(
        startDate: _startDate!,
        endDate: _endDate!,
      );
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && picked.isAfter(_endDate!)) {
          _endDate = picked;
        }
      });
      _updateDateFilter();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        if (_startDate != null && picked.isBefore(_startDate!)) {
          _startDate = picked;
        }
      });
      _updateDateFilter();
    }
  }

  void _updateDateFilter() {
    if (_startDate != null && _endDate != null) {
      ref.read(dateFilterProvider.notifier).state = DateRange(
        startDate: _startDate!,
        endDate: _endDate!,
      );
    }
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    ref.read(dateFilterProvider.notifier).state = null;
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
            icon: const Icon(Icons.filter_list_off),
            onPressed: _clearFilter,
            tooltip: 'Filtreyi Temizle',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tarih filtresi
          _buildDateFilter(),

          // İstatistik özeti
          _buildSummaryCard(filteredRecords),

          // Kayıt listesi
          Expanded(child: _buildRecordsList(filteredRecords)),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tarih Aralığı',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'Başlangıç',
                  date: _startDate,
                  onTap: _selectStartDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateButton(
                  label: 'Bitiş',
                  date: _endDate,
                  onTap: _selectEndDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? '${date.day}/${date.month}/${date.year}' : 'Seçiniz',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: date != null ? AppTheme.textPrimaryColor : AppTheme.textLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<CheckInOut> records) {
    final validRecords = records.where((r) => r.workDuration != null).toList();
    final totalHours = validRecords.fold<double>(
      0,
      (sum, record) => sum + (record.workDuration!.inMinutes / 60.0),
    );
    final averageHours = validRecords.isNotEmpty ? totalHours / validRecords.length : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Toplam Gün',
              '${records.length}',
              Icons.calendar_today,
              AppTheme.primaryColor,
            ),
          ),
          Container(width: 1, height: 40, color: AppTheme.textLightColor),
          Expanded(
            child: _buildSummaryItem(
              'Toplam Saat',
              '${totalHours.toStringAsFixed(1)}h',
              Icons.access_time,
              AppTheme.secondaryColor,
            ),
          ),
          Container(width: 1, height: 40, color: AppTheme.textLightColor),
          Expanded(
            child: _buildSummaryItem(
              'Ortalama',
              '${averageHours.toStringAsFixed(1)}h',
              Icons.trending_up,
              AppTheme.checkInColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondaryColor),
        ),
      ],
    );
  }

  Widget _buildRecordsList(List<CheckInOut> records) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textLightColor),
            const SizedBox(height: 16),
            Text(
              'Kayıt bulunamadı',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Seçilen tarih aralığında kayıt bulunmuyor.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textLightColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return CheckInOutCard(
          date: record.dateString,
          checkInTime: record.checkInTimeString,
          checkOutTime: record.checkOutTimeString,
          workDuration: record.workDurationString,
          onTap: () => _showRecordDetails(record),
          onEdit: () => _editRecord(record),
          onDelete: () => _deleteRecord(record),
        );
      },
    );
  }

  void _showRecordDetails(CheckInOut record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Kayıt Detayları',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tarih', record.dateString),
            const SizedBox(height: 8),
            _buildDetailRow('Giriş Saati', record.checkInTimeString),
            const SizedBox(height: 8),
            _buildDetailRow('Çıkış Saati', record.checkOutTimeString),
            const SizedBox(height: 8),
            _buildDetailRow('Toplam Süre', record.workDurationString),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryColor),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editRecord(CheckInOut record) async {
    context.pushNamed('edit-record', extra: record);
  }

  Future<void> _deleteRecord(CheckInOut record) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: AppTheme.errorColor),
            const SizedBox(width: 8),
            Text(
              'Kayıt Sil',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.errorColor),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu kaydı silmek istediğinizden emin misiniz?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.dateString,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Giriş: ${record.checkInTimeString} • Çıkış: ${record.checkOutTimeString}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bu işlem geri alınamaz.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.errorColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
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
    }
  }
}
