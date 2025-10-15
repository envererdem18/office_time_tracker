import 'package:flutter/material.dart';

import '../../models/check_in_out.dart';
import '../../theme/app_theme.dart';
import '../organisms/custom_card.dart';

class RecordsListWidget extends StatefulWidget {
  final List<CheckInOut> records;
  final Function(CheckInOut) onTap;
  final Function(CheckInOut) onEdit;
  final Function(CheckInOut) onDelete;
  final int itemsPerPage;

  const RecordsListWidget({
    super.key,
    required this.records,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.itemsPerPage = 20,
  });

  @override
  State<RecordsListWidget> createState() => _RecordsListWidgetState();
}

class _RecordsListWidgetState extends State<RecordsListWidget> {
  int _currentPage = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    final totalPages = (widget.records.length / widget.itemsPerPage).ceil();
    if (_currentPage < totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  List<CheckInOut> get _displayedRecords {
    final endIndex = (_currentPage + 1) * widget.itemsPerPage;
    return widget.records.take(endIndex).toList();
  }

  @override
  void didUpdateWidget(RecordsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kayıtlar değiştiğinde sayfalamayı sıfırla
    if (oldWidget.records != widget.records) {
      setState(() {
        _currentPage = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
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
        ),
      );
    }

    final displayedRecords = _displayedRecords;
    final hasMoreData = displayedRecords.length < widget.records.length;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Kayıt listesi
          ...displayedRecords.map((record) {
            return CheckInOutCard(
              date: record.dateString,
              checkInTime: record.checkInTimeString,
              checkOutTime: record.checkOutTimeString,
              workDuration: record.workDurationString,
              commuteDepartureTime: record.commuteDepartureTimeString,
              returnArrivalTime: record.returnArrivalTimeString,
              outboundCommuteDuration: record.outboundCommuteDurationString,
              returnCommuteDuration: record.returnCommuteDurationString,
              onTap: () => widget.onTap(record),
              onEdit: () => widget.onEdit(record),
              onDelete: () => widget.onDelete(record),
            );
          }),

          // Loading veya "Daha fazla yükle" butonu
          if (hasMoreData) ...[
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _loadMore,
                icon: const Icon(Icons.expand_more),
                label: Text(
                  'Daha fazla yükle (${widget.records.length - displayedRecords.length} kayıt)',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.primaryColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Toplam kayıt sayısı bilgisi
          if (widget.records.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.textLightColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Toplam ${widget.records.length} kayıt • Gösterilen ${displayedRecords.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
