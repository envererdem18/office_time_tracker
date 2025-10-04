import 'package:flutter/material.dart';

import '../../models/check_in_out.dart';
import '../../theme/app_theme.dart';
import '../atoms/detail_row_widget.dart';

class RecordDetailsDialog extends StatelessWidget {
  final CheckInOut record;

  const RecordDetailsDialog({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Kayıt Detayları',
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRowWidget(label: 'Tarih', value: record.dateString),
          const SizedBox(height: 8),
          DetailRowWidget(label: 'Giriş Saati', value: record.checkInTimeString),
          const SizedBox(height: 8),
          DetailRowWidget(label: 'Çıkış Saati', value: record.checkOutTimeString),
          const SizedBox(height: 8),
          DetailRowWidget(label: 'Toplam Süre', value: record.workDurationString),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kapat'),
        ),
      ],
    );
  }
}
