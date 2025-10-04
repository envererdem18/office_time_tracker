import 'package:flutter/material.dart';

import '../../models/check_in_out.dart';
import '../molecules/summary_card_widget.dart';

class HistorySummaryWidget extends StatelessWidget {
  final List<CheckInOut> records;

  const HistorySummaryWidget({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final validRecords = records.where((r) => r.workDuration != null).toList();
    final totalHours = validRecords.fold<double>(
      0,
      (sum, record) => sum + (record.workDuration!.inMinutes / 60.0),
    );
    final averageHours = validRecords.isNotEmpty ? totalHours / validRecords.length : 0.0;

    return SummaryCardWidget(
      totalDays: records.length,
      totalHours: totalHours,
      averageHours: averageHours,
    );
  }
}
