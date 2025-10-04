import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/summary_item_widget.dart';

class SummaryCardWidget extends StatelessWidget {
  final int totalDays;
  final double totalHours;
  final double averageHours;

  const SummaryCardWidget({
    super.key,
    required this.totalDays,
    required this.totalHours,
    required this.averageHours,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SummaryItemWidget(
              label: 'Toplam Gün',
              value: '$totalDays',
              icon: Icons.calendar_today,
              color: AppTheme.primaryColor,
            ),
          ),
          Container(width: 1, height: 40, color: AppTheme.textLightColor),
          Expanded(
            child: SummaryItemWidget(
              label: 'Toplam Saat',
              value: '${totalHours.toStringAsFixed(1)}h',
              icon: Icons.access_time,
              color: AppTheme.secondaryColor,
            ),
          ),
          Container(width: 1, height: 40, color: AppTheme.textLightColor),
          Expanded(
            child: SummaryItemWidget(
              label: 'Ortalama',
              value: '${averageHours.toStringAsFixed(1)}h',
              icon: Icons.trending_up,
              color: AppTheme.checkInColor,
            ),
          ),
        ],
      ),
    );
  }
}
