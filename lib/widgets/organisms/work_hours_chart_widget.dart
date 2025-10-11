import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../providers/database_provider.dart';
import '../../theme/app_theme.dart';

class WorkHoursChartWidget extends StatelessWidget {
  final Statistics statistics;

  const WorkHoursChartWidget({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    if (statistics.dailyStats.isEmpty) {
      return _buildEmptyChart(context, 'Çalışma saati verisi bulunamadı');
    }

    // Bar chart için veri noktalarını hazırla
    final barGroups = statistics.dailyStats.asMap().entries.map((entry) {
      final hours = entry.value.workHours;
      // 8 saatin altı kırmızı, üstü yeşil
      final color = hours < 8
          ? AppTheme.errorColor
          : (hours > 9 ? AppTheme.successColor : AppTheme.primaryColor);

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: hours,
            color: color,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    // Etiket gösterim aralığını hesapla (maksimum 8 etiket göster)
    final dataLength = statistics.dailyStats.length;
    final interval = (dataLength / 8).ceil();

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
            'Günlük Çalışma Saatleri',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          // Renk açıklama
          Row(
            children: [
              _buildLegendItem('< 8 saat', AppTheme.errorColor),
              const SizedBox(width: 16),
              _buildLegendItem('8-9 saat', AppTheme.primaryColor),
              const SizedBox(width: 16),
              _buildLegendItem('> 9 saat', AppTheme.successColor),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: 12,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    // 8 saatlik çizgiyi vurgula
                    if (value == 8) {
                      return const FlLine(
                        color: AppTheme.primaryColor,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    }
                    return const FlLine(color: AppTheme.textLightColor, strokeWidth: 0.5);
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}h',
                          style: TextStyle(
                            color: value == 8
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondaryColor,
                            fontSize: 11,
                            fontWeight: value == 8 ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        // Sadece belirli aralıklarla etiket göster
                        if (index % interval != 0 && index != dataLength - 1) {
                          return const SizedBox.shrink();
                        }
                        if (index < 0 || index >= statistics.dailyStats.length) {
                          return const SizedBox.shrink();
                        }
                        final date = statistics.dailyStats[index].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final date = statistics.dailyStats[groupIndex].date;
                      final hours = rod.toY.toInt();
                      final minutes = ((rod.toY - hours) * 60).toInt();
                      return BarTooltipItem(
                        '${date.day}/${date.month}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '${hours}s ${minutes}dk',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 10),
        ),
      ],
    );
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
