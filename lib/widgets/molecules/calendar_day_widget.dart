import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class CalendarDayWidget extends StatelessWidget {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool isInRange;
  final bool isPastDate;
  final VoidCallback? onTap;

  const CalendarDayWidget({
    super.key,
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.isInRange,
    required this.isPastDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    Color? textColor;

    if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
    } else if (isInRange) {
      backgroundColor = AppTheme.primaryColor.withValues(alpha: 0.2);
      textColor = AppTheme.primaryColor;
    } else if (isToday) {
      backgroundColor = AppTheme.primaryColor.withValues(alpha: 0.1);
      textColor = AppTheme.primaryColor;
    } else if (!isCurrentMonth || isPastDate) {
      textColor = AppTheme.textLightColor;
    } else {
      textColor = AppTheme.textPrimaryColor;
    }

    return GestureDetector(
      onTap: (!isCurrentMonth || isPastDate) ? null : onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
