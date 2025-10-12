import 'package:flutter/material.dart';

import '../../providers/database_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/summary_item_widget.dart';

class StatisticsSummaryWidget extends StatelessWidget {
  final Statistics statistics;

  const StatisticsSummaryWidget({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        children: [
          // İlk satır - Temel metrikler
          Row(
            children: [
              Expanded(
                child: SummaryItemWidget(
                  label: 'Toplam Gün',
                  value: '${statistics.totalWorkDays}',
                  icon: Icons.calendar_today,
                  color: AppTheme.primaryColor,
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.textLightColor),
              Expanded(
                child: SummaryItemWidget(
                  label: 'Toplam Saat',
                  value: '${statistics.totalWorkHours.toStringAsFixed(1)}h',
                  icon: Icons.access_time,
                  color: AppTheme.secondaryColor,
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.textLightColor),
              Expanded(
                child: SummaryItemWidget(
                  label: 'Ortalama',
                  value: '${statistics.averageWorkHours.toStringAsFixed(1)}h',
                  icon: Icons.trending_up,
                  color: AppTheme.checkInColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: AppTheme.textLightColor),
          const SizedBox(height: 8),
          // İkinci satır - Geç kalma ve fazla mesai metrikleri
          Row(
            children: [
              Expanded(
                child: SummaryItemWidget(
                  label: 'Geç Kalma',
                  value: '${statistics.lateCheckIns}',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFFF9800),
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.textLightColor),
              Expanded(
                child: SummaryItemWidget(
                  label: 'Ort. Geç',
                  value: statistics.averageLateMinutes > 0
                      ? '${statistics.averageLateMinutes.toStringAsFixed(0)}dk'
                      : '-',
                  icon: Icons.schedule,
                  color: const Color(0xFFFF5722),
                ),
              ),
              Container(width: 1, height: 40, color: AppTheme.textLightColor),
              Expanded(
                child: SummaryItemWidget(
                  label: 'Fazla Mesai',
                  value: statistics.totalOvertimeHours > 0
                      ? '${statistics.totalOvertimeHours.toStringAsFixed(1)}h'
                      : '-',
                  icon: Icons.work_history,
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
