import 'package:flutter/material.dart';

import '../../models/check_in_out.dart';
import '../../theme/app_theme.dart';
import '../organisms/custom_card.dart';

class RecordsListWidget extends StatelessWidget {
  final List<CheckInOut> records;
  final Function(CheckInOut) onTap;
  final Function(CheckInOut) onEdit;
  final Function(CheckInOut) onDelete;

  const RecordsListWidget({
    super.key,
    required this.records,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: AppTheme.textLightColor),
              const SizedBox(height: 16),
              Text(
                'Kayıt bulunamadı',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppTheme.textSecondaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Seçilen tarih aralığında kayıt bulunmuyor.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textLightColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: records.map((record) {
        return CheckInOutCard(
          date: record.dateString,
          checkInTime: record.checkInTimeString,
          checkOutTime: record.checkOutTimeString,
          workDuration: record.workDurationString,
          onTap: () => onTap(record),
          onEdit: () => onEdit(record),
          onDelete: () => onDelete(record),
        );
      }).toList(),
    );
  }
}
