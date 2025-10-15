import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../providers/database_provider.dart';
import '../../theme/app_theme.dart';

class CheckInTimesChartWidget extends StatelessWidget {
  final Statistics statistics;

  const CheckInTimesChartWidget({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    if (statistics.dailyStats.isEmpty) {
      return _buildEmptyChart(context, 'Giriş saati verisi bulunamadı');
    }

    // Bar chart için veri noktalarını hazırla
    final barGroups = statistics.dailyStats.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.checkInHour,
            color: AppTheme.checkInColor,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    // Etiket gösterim aralığını hesapla (maksimum 8 etiket göster)
    final dataLength = statistics.dailyStats.length;
    final interval = (dataLength / 8).ceil();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
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
                  'Günlük Giriş Saatleri',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppTheme.checkInColor),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceEvenly,
                      maxY: 11,
                      minY: 7,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return const FlLine(
                            color: AppTheme.textLightColor,
                            strokeWidth: 0.5,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}:00',
                                style: const TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 11,
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
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: barGroups,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: AppTheme.checkInColor.withValues(alpha: 0.9),
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final date = statistics.dailyStats[groupIndex].date;
                            final hour = rod.toY.toInt();
                            final minute = ((rod.toY - hour) * 60).toInt();
                            return BarTooltipItem(
                              '${date.day}/${date.month}\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
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
          ),
        ],
      ),
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
