import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../providers/database_provider.dart';
import '../../theme/app_theme.dart';

class CommuteTimesChartWidget extends StatelessWidget {
  final Statistics statistics;

  const CommuteTimesChartWidget({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    // Yol verisi olan günleri filtrele
    final commuteData =
        statistics.dailyStats
            .where(
              (stat) => stat.totalCommuteMinutes != null && stat.totalCommuteMinutes! > 0,
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (commuteData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Yol verisi bulunamadı',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yol hesaplama özelliğini aktif hale getirerek\nyol sürelerinizi takip edebilirsiniz',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    // Son 30 gün veya tüm veriler (hangisi daha azsa)
    final displayData = commuteData.length > 30
        ? commuteData.sublist(commuteData.length - 30)
        : commuteData;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grafik
          Container(
            height: 300,
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
                  'Günlük Yol Süreleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(displayData),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: AppTheme.primaryColor.withValues(alpha: 0.9),
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final stat = displayData[group.x.toInt()];
                            final label = rodIndex == 0 ? 'Gidiş' : 'Dönüş';
                            final minutes = rodIndex == 0
                                ? stat.outboundCommuteMinutes ?? 0
                                : stat.returnCommuteMinutes ?? 0;
                            return BarTooltipItem(
                              '$label\n${_formatMinutes(minutes)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < 0 ||
                                  value.toInt() >= displayData.length) {
                                return const Text('');
                              }
                              final date = displayData[value.toInt()].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '${date.day}/${date.month}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              );
                            },
                            reservedSize: 40,
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 10,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(color: AppTheme.textLightColor, strokeWidth: 1);
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _generateBarGroups(displayData),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem('Gidiş', Colors.blue),
                    const SizedBox(width: 24),
                    _buildLegendItem('Dönüş', const Color(0xFF1A237E)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<DailyStats> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final outbound = stat.outboundCommuteMinutes ?? 0;
      final returnMinutes = stat.returnCommuteMinutes ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: outbound,
            color: Colors.blue,
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: returnMinutes,
            color: const Color(0xFF1A237E),
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY(List<DailyStats> data) {
    double maxValue = 0;
    for (final stat in data) {
      final outbound = stat.outboundCommuteMinutes ?? 0;
      final returnMinutes = stat.returnCommuteMinutes ?? 0;
      if (outbound > maxValue) maxValue = outbound;
      if (returnMinutes > maxValue) maxValue = returnMinutes;
    }
    // Round up to nearest 10
    return ((maxValue / 10).ceil() * 10).toDouble() + 10;
  }

  String _formatMinutes(double minutes) {
    if (minutes < 60) {
      return '${minutes.toInt()} dk';
    }
    final hours = (minutes / 60).floor();
    final remainingMinutes = (minutes % 60).toInt();
    if (remainingMinutes == 0) {
      return '$hours saat';
    }
    return '$hours saat $remainingMinutes dk';
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
