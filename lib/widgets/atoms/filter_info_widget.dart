import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class FilterInfoWidget extends StatelessWidget {
  final bool showAllTime;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterInfoWidget({
    super.key,
    required this.showAllTime,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            showAllTime
                ? Icons.all_inclusive
                : (startDate != null && endDate != null)
                ? Icons.date_range
                : Icons.schedule,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              showAllTime
                  ? 'Tüm zamanlar gösteriliyor'
                  : startDate != null && endDate != null
                  ? 'Filtre: ${startDate!.day}/${startDate!.month}/${startDate!.year} - ${endDate!.day}/${endDate!.month}/${endDate!.year}'
                  : startDate != null
                  ? 'Başlangıç: ${startDate!.day}/${startDate!.month}/${startDate!.year}'
                  : 'Tarih seçiliyor...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
