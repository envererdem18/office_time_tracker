import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../providers/database_provider.dart';
import '../../theme/app_theme.dart';

class DistributionChartWidget extends StatelessWidget {
  final Statistics statistics;

  const DistributionChartWidget({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    if (statistics.workHoursDistribution.isEmpty) {
      return _buildEmptyChart(context, 'Dağılım verisi bulunamadı');
    }

    final sections = statistics.workHoursDistribution.entries.map((entry) {
      final percentage = statistics.totalWorkDays > 0
          ? (entry.value / statistics.totalWorkDays) * 100
          : 0.0;

      Color color = _getColorForCategory(entry.key);

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      margin: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Çalışma Saati Dağılımı',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 8,
                    children: statistics.workHoursDistribution.entries.map((entry) {
                      Color color = _getColorForCategory(entry.key);

                      return SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 8,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  entry.key,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                Text(
                                  '${entry.value} gün',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textPrimaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case '<8 saat':
        return AppTheme.checkOutColor;
      case '8-9 saat':
        return AppTheme.checkInColor;
      case '>9 saat':
        return AppTheme.primaryColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  Widget _buildEmptyChart(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 64, color: AppTheme.textLightColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
