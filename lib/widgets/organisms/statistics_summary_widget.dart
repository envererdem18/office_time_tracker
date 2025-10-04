import 'package:flutter/material.dart';

import '../../providers/database_provider.dart';
import '../molecules/summary_card_widget.dart';

class StatisticsSummaryWidget extends StatelessWidget {
  final Statistics statistics;

  const StatisticsSummaryWidget({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return SummaryCardWidget(
      totalDays: statistics.totalWorkDays,
      totalHours: statistics.totalWorkHours,
      averageHours: statistics.averageWorkHours,
    );
  }
}
