import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import 'custom_calendar_widget.dart';

class FilterBottomSheetWidget extends ConsumerStatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool initialMonthMode;
  final Set<int> initialSelectedMonths;
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final Function(bool, Set<int>) onStateChanged;
  final VoidCallback onClear;

  const FilterBottomSheetWidget({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.initialMonthMode,
    required this.initialSelectedMonths,
    required this.onDateRangeChanged,
    required this.onStateChanged,
    required this.onClear,
  });

  @override
  ConsumerState<FilterBottomSheetWidget> createState() => _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends ConsumerState<FilterBottomSheetWidget> {
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _currentMonth = DateTime.now();
  bool _isMonthSelectionMode = false;
  Set<int> _selectedMonths = {};

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _isMonthSelectionMode = widget.initialMonthMode;
    _selectedMonths = Set<int>.from(widget.initialSelectedMonths);
    if (_startDate != null) {
      _currentMonth = DateTime(_startDate!.year, _startDate!.month);
    }
  }

  void _onDateTap(DateTime date) {
    setState(() {
      // Eğer ay seçimi varsa, onu temizle
      if (_selectedMonths.isNotEmpty) {
        _selectedMonths.clear();
        _isMonthSelectionMode = false;
      }

      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // Yeni seçim başlat
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        // Bitiş tarihini seç
        if (date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });

    // Eş zamanlı filtreleme
    widget.onDateRangeChanged(_startDate, _endDate);
    widget.onStateChanged(_isMonthSelectionMode, _selectedMonths);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _clearSelection() {
    setState(() {
      _startDate = null;
      _endDate = null;
      // Görünüm türünü koruyarak sadece seçimleri temizle
      _selectedMonths.clear();
      // _isMonthSelectionMode değiştirme - mevcut görünümde kal
    });
    widget.onClear();
    widget.onDateRangeChanged(null, null);
    widget.onStateChanged(_isMonthSelectionMode, <int>{});
  }

  bool _hasActiveFilter() {
    bool hasDateRange = _startDate != null && _endDate != null;
    bool hasMonthSelection = _selectedMonths.isNotEmpty;
    return hasDateRange || hasMonthSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppTheme.textLightColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            height: 80,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.tune, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Tarih Aralığı Seç',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 80,
                  child: (_hasActiveFilter())
                      ? TextButton(
                          onPressed: _clearSelection,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            'Temizle',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Selected Range Info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (_startDate != null && _endDate != null)
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  (_startDate != null && _endDate != null)
                      ? Icons.date_range
                      : Icons.all_inclusive,
                  color: (_startDate != null && _endDate != null)
                      ? AppTheme.primaryColor
                      : AppTheme.successColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _startDate != null && _endDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : _startDate != null
                        ? 'Başlangıç: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Tüm Zamanlar',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: (_startDate != null && _endDate != null)
                          ? AppTheme.primaryColor
                          : AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_startDate != null && _endDate != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isMonthSelectionMode = true;
                        _startDate = null;
                        _endDate = null;
                      });
                      widget.onStateChanged(true, _selectedMonths);
                      widget.onDateRangeChanged(null, null);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_endDate!.difference(_startDate!).inDays + 1} gün',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Calendar
          Expanded(
            child: CustomCalendarWidget(
              currentMonth: _currentMonth,
              startDate: _startDate,
              endDate: _endDate,
              initialMonthMode: _isMonthSelectionMode,
              initialSelectedMonths: _selectedMonths,
              onDateTap: _onDateTap,
              onDateRangeChanged: (start, end) {
                setState(() {
                  // Ay filtrelemesi yapıldığında seçili ayları koru
                  bool isMonthFiltering =
                      _isMonthSelectionMode && _selectedMonths.isNotEmpty;

                  _startDate = start;
                  _endDate = end;

                  // Sadece gün seçimi yapıldığında ay seçimlerini temizle
                  if (start != null && end != null && !isMonthFiltering) {
                    _selectedMonths.clear();
                    _isMonthSelectionMode = false;
                  }
                });
                widget.onDateRangeChanged(start, end);
              },
              onStateChanged: (isMonthMode, selectedMonths) {
                setState(() {
                  _isMonthSelectionMode = isMonthMode;
                  _selectedMonths = selectedMonths;
                  if (selectedMonths.isNotEmpty) {
                    _startDate = null;
                    _endDate = null;
                  }
                });
                widget.onStateChanged(isMonthMode, selectedMonths);
              },
              onPreviousMonth: _previousMonth,
              onNextMonth: _nextMonth,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
