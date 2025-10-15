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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailRowWidget(label: 'Tarih', value: record.dateString),
            // Yol bilgileri varsa göster
            if (record.commuteDepartureTime != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Yol Bilgileri',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DetailRowWidget(
                label: 'Yola Çıkış',
                value: record.commuteDepartureTimeString,
                iconData: Icons.directions_car,
                iconColor: Colors.blue,
              ),
              if (record.outboundCommuteDuration != null) ...[
                const SizedBox(height: 4),
                DetailRowWidget(
                  label: '  Gidiş Süresi',
                  value: record.outboundCommuteDurationString,
                ),
              ],
            ],
            const SizedBox(height: 8),
            DetailRowWidget(label: 'Giriş Saati', value: record.checkInTimeString),
            const SizedBox(height: 8),
            DetailRowWidget(label: 'Çıkış Saati', value: record.checkOutTimeString),
            const SizedBox(height: 8),
            DetailRowWidget(label: 'Toplam Çalışma', value: record.workDurationString),
            // Dönüş bilgileri varsa göster
            if (record.returnArrivalTime != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              DetailRowWidget(
                label: 'Eve Varış',
                value: record.returnArrivalTimeString,
                iconData: Icons.home,
                iconColor: const Color(0xFF1A237E),
              ),
              if (record.returnCommuteDuration != null) ...[
                const SizedBox(height: 4),
                DetailRowWidget(
                  label: '  Dönüş Süresi',
                  value: record.returnCommuteDurationString,
                ),
              ],
              if (record.totalCommuteDuration != null) ...[
                const SizedBox(height: 8),
                DetailRowWidget(
                  label: 'Toplam Yol',
                  value: record.totalCommuteDurationString,
                  iconData: Icons.swap_horiz,
                  iconColor: AppTheme.textSecondaryColor,
                ),
              ],
            ],
          ],
        ),
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
