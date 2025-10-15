import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../molecules/calendar_day_widget.dart';
import '../molecules/month_grid_widget.dart';

class CustomCalendarWidget extends StatefulWidget {
  final DateTime currentMonth;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool initialMonthMode;
  final Set<int> initialSelectedMonths;
  final Function(DateTime) onDateTap;
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final Function(bool, Set<int>) onStateChanged;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback? onShowAllTime;
  final bool showAllTimeButton;

  const CustomCalendarWidget({
    super.key,
    required this.currentMonth,
    required this.startDate,
    required this.endDate,
    required this.initialMonthMode,
    required this.initialSelectedMonths,
    required this.onDateTap,
    required this.onDateRangeChanged,
    required this.onStateChanged,
    required this.onPreviousMonth,
    required this.onNextMonth,
    this.onShowAllTime,
    this.showAllTimeButton = true,
  });

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late PageController _pageController;
  late DateTime _currentMonth;
  late bool _isMonthSelectionMode;
  late Set<int> _selectedMonths;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.currentMonth;
    _isMonthSelectionMode = widget.initialMonthMode;
    _selectedMonths = Set<int>.from(widget.initialSelectedMonths);
    _pageController = PageController(initialPage: 1000);
  }

  @override
  void didUpdateWidget(CustomCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMonth != widget.currentMonth) {
      _currentMonth = widget.currentMonth;
    }

    // Sadece temizleme işlemi durumunda state'i güncelle
    // Temizleme: seçili aylar boş ve önceden seçili aylar vardı
    bool isClearOperation =
        widget.initialSelectedMonths.isEmpty && _selectedMonths.isNotEmpty;

    if (isClearOperation) {
      setState(() {
        _selectedMonths.clear();
        // Görünüm türünü değiştirme - mevcut modda kal
      });
      return;
    }

    // Parent'tan gelen state değişikliklerini algıla ve güncelle
    bool shouldUpdateMonthMode = oldWidget.initialMonthMode != widget.initialMonthMode;
    bool shouldUpdateSelectedMonths = !_setEquals(
      oldWidget.initialSelectedMonths,
      widget.initialSelectedMonths,
    );

    if (shouldUpdateMonthMode || shouldUpdateSelectedMonths) {
      setState(() {
        _isMonthSelectionMode = widget.initialMonthMode;
        _selectedMonths = Set<int>.from(widget.initialSelectedMonths);
      });
    }
  }

  // Helper method to compare sets
  bool _setEquals<T>(Set<T> set1, Set<T> set2) {
    if (set1.length != set2.length) return false;
    return set1.containsAll(set2) && set2.containsAll(set1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    final monthDifference = page - 1000;
    final newMonth = DateTime(
      widget.currentMonth.year,
      widget.currentMonth.month + monthDifference,
    );

    setState(() {
      _currentMonth = newMonth;
    });
  }

  void _enterMonthSelectionMode() {
    setState(() {
      _isMonthSelectionMode = true;
    });
    widget.onStateChanged(_isMonthSelectionMode, _selectedMonths);
  }

  void _exitMonthSelectionMode() {
    setState(() {
      _isMonthSelectionMode = false;
      _selectedMonths.clear();
    });
    widget.onStateChanged(_isMonthSelectionMode, _selectedMonths);
  }

  void _onMonthTap(int month) {
    setState(() {
      if (_selectedMonths.contains(month)) {
        _selectedMonths.remove(month);
      } else {
        _selectedMonths.add(month);
      }
    });

    widget.onStateChanged(_isMonthSelectionMode, _selectedMonths);

    // Eş zamanlı filtreleme - ay seçimi değiştiğinde hemen filtrele
    _applyMonthFilter();
  }

  void _applyMonthFilter() {
    if (_selectedMonths.isEmpty) {
      widget.onDateRangeChanged(null, null);
      return;
    }

    final sortedMonths = _selectedMonths.toList()..sort();
    final firstMonth = sortedMonths.first;
    final lastMonth = sortedMonths.last;

    final startDate = DateTime(_currentMonth.year, firstMonth, 1);
    final endDate = DateTime(_currentMonth.year, lastMonth + 1, 0);

    widget.onDateRangeChanged(startDate, endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month Navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              if (!_isMonthSelectionMode)
                IconButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icon(Icons.chevron_left, color: AppTheme.primaryColor),
                )
              else
                IconButton(
                  onPressed: _exitMonthSelectionMode,
                  icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
                ),
              Expanded(
                child: InkWell(
                  onTap: _isMonthSelectionMode
                      ? _exitMonthSelectionMode
                      : _enterMonthSelectionMode,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _isMonthSelectionMode
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _isMonthSelectionMode
                          ? '${_currentMonth.year} - Ay Seçimi'
                          : _getMonthYearString(_currentMonth),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              if (!_isMonthSelectionMode)
                IconButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Content Area
        Expanded(
          child: _isMonthSelectionMode
              ? MonthGridWidget(
                  selectedMonths: _selectedMonths,
                  onMonthTap: _onMonthTap,
                  onShowAllTime: widget.onShowAllTime,
                  showAllTimeButton: widget.showAllTimeButton,
                )
              : Column(
                  children: [
                    // Weekday Headers
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                            .map(
                              (day) => Expanded(
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Calendar Grid with PageView
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        itemBuilder: (context, index) {
                          final monthDifference = index - 1000;
                          final displayMonth = DateTime(
                            widget.currentMonth.year,
                            widget.currentMonth.month + monthDifference,
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildCalendarGrid(context, displayMonth),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context, DateTime displayMonth) {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final previousMonth = DateTime(displayMonth.year, displayMonth.month - 1);
    final lastDayOfPreviousMonth = DateTime(displayMonth.year, displayMonth.month, 0);
    final daysFromPreviousMonth = firstDayWeekday - 1;

    List<Widget> dayWidgets = [];

    // Önceki ayın günleri
    for (int i = daysFromPreviousMonth; i > 0; i--) {
      final day = lastDayOfPreviousMonth.day - i + 1;
      final date = DateTime(previousMonth.year, previousMonth.month, day);
      dayWidgets.add(_buildDayWidget(context, date, isCurrentMonth: false));
    }

    // Bu ayın günleri
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      dayWidgets.add(_buildDayWidget(context, date, isCurrentMonth: true));
    }

    // Sonraki ayın günleri
    final nextMonth = DateTime(displayMonth.year, displayMonth.month + 1);
    int remainingDays = 42 - dayWidgets.length;
    for (int day = 1; day <= remainingDays; day++) {
      final date = DateTime(nextMonth.year, nextMonth.month, day);
      dayWidgets.add(_buildDayWidget(context, date, isCurrentMonth: false));
    }

    return GridView.count(crossAxisCount: 7, children: dayWidgets);
  }

  Widget _buildDayWidget(
    BuildContext context,
    DateTime date, {
    required bool isCurrentMonth,
  }) {
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected =
        (widget.startDate != null && _isSameDay(date, widget.startDate)) ||
        (widget.endDate != null && _isSameDay(date, widget.endDate));
    final isInRange =
        (widget.startDate != null && widget.endDate != null) && _isDateInRange(date);
    final isPastDate = date.isAfter(DateTime.now());

    return CalendarDayWidget(
      date: date,
      isCurrentMonth: isCurrentMonth,
      isToday: isToday,
      isSelected: isSelected,
      isInRange: isInRange,
      isPastDate: isPastDate,
      onTap: () => widget.onDateTap(date),
    );
  }

  bool _isSameDay(DateTime date1, DateTime? date2) {
    if (date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isDateInRange(DateTime date) {
    if (widget.startDate == null || widget.endDate == null) return false;
    return date.isAfter(widget.startDate!) && date.isBefore(widget.endDate!);
  }

  String _getMonthYearString(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }
}
