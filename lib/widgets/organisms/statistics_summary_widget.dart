import 'package:flutter/material.dart';

import '../../providers/database_provider.dart';
import '../../theme/app_theme.dart';
import '../atoms/summary_item_widget.dart';

class StatisticsSummaryWidget extends StatefulWidget {
  final Statistics statistics;

  const StatisticsSummaryWidget({super.key, required this.statistics});

  @override
  State<StatisticsSummaryWidget> createState() => _StatisticsSummaryWidgetState();
}

class _StatisticsSummaryWidgetState extends State<StatisticsSummaryWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: const Text(
            'Özet Bilgiler',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: AppTheme.primaryColor,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // İlk satır - Temel metrikler
                  Row(
                    children: [
                      Expanded(
                        child: SummaryItemWidget(
                          label: 'Toplam Gün',
                          value: '${widget.statistics.totalWorkDays}',
                          icon: Icons.calendar_today,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppTheme.textLightColor),
                      Expanded(
                        child: SummaryItemWidget(
                          label: 'Toplam Saat',
                          value:
                              '${widget.statistics.totalWorkHours.toStringAsFixed(1)}h',
                          icon: Icons.access_time,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppTheme.textLightColor),
                      Expanded(
                        child: SummaryItemWidget(
                          label: 'Ortalama',
                          value:
                              '${widget.statistics.averageWorkHours.toStringAsFixed(1)}h',
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
                          value: '${widget.statistics.lateCheckIns}',
                          icon: Icons.warning_amber_rounded,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppTheme.textLightColor),
                      Expanded(
                        child: SummaryItemWidget(
                          label: 'Ort. Geç',
                          value: widget.statistics.averageLateMinutes > 0
                              ? '${widget.statistics.averageLateMinutes.toStringAsFixed(0)}dk'
                              : '-',
                          icon: Icons.schedule,
                          color: const Color(0xFFFF5722),
                        ),
                      ),
                      Container(width: 1, height: 40, color: AppTheme.textLightColor),
                      Expanded(
                        child: SummaryItemWidget(
                          label: 'Fazla Mesai',
                          value: widget.statistics.totalOvertimeMinutes > 0
                              ? _formatOvertimeMinutes(
                                  widget.statistics.totalOvertimeMinutes,
                                )
                              : '-',
                          icon: Icons.work_history,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                  // Üçüncü satır - Yol metrikleri (eğer yol verisi varsa)
                  if (widget.statistics.daysWithCommute > 0) ...[
                    const SizedBox(height: 8),
                    Container(height: 1, color: AppTheme.textLightColor),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SummaryItemWidget(
                            label: 'Ort. Gidiş',
                            value: _formatCommuteMinutes(
                              widget.statistics.averageOutboundCommuteMinutes,
                            ),
                            icon: Icons.arrow_forward,
                            color: Colors.blue,
                          ),
                        ),
                        Container(width: 1, height: 40, color: AppTheme.textLightColor),
                        Expanded(
                          child: SummaryItemWidget(
                            label: 'Ort. Dönüş',
                            value: _formatCommuteMinutes(
                              widget.statistics.averageReturnCommuteMinutes,
                            ),
                            icon: Icons.arrow_back,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                        Container(width: 1, height: 40, color: AppTheme.textLightColor),
                        Expanded(
                          child: SummaryItemWidget(
                            label: 'Ort. Toplam',
                            value: _formatCommuteMinutes(
                              widget.statistics.averageTotalCommuteMinutes,
                            ),
                            icon: Icons.swap_horiz,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatOvertimeMinutes(double minutes) {
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(0)}dk';
    }
    final hours = (minutes / 60).floor();
    final remainingMinutes = (minutes % 60).toInt();
    if (remainingMinutes == 0) {
      return '${hours}s';
    }
    return '${hours}s ${remainingMinutes}dk';
  }

  String _formatCommuteMinutes(double minutes) {
    if (minutes == 0) {
      return '-';
    }
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(0)}dk';
    }
    final hours = (minutes / 60).floor();
    final remainingMinutes = (minutes % 60).toInt();
    if (remainingMinutes == 0) {
      return '${hours}s';
    }
    return '${hours}s ${remainingMinutes}dk';
  }
}
