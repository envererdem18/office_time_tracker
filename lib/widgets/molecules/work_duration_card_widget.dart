import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class WorkDurationCardWidget extends StatelessWidget {
  final TimeOfDay checkInTime;
  final TimeOfDay checkOutTime;

  const WorkDurationCardWidget({
    super.key,
    required this.checkInTime,
    required this.checkOutTime,
  });

  @override
  Widget build(BuildContext context) {
    final checkIn = DateTime(2000, 1, 1, checkInTime.hour, checkInTime.minute);
    final checkOut = DateTime(2000, 1, 1, checkOutTime.hour, checkOutTime.minute);
    final duration = checkOut.difference(checkIn);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.schedule, color: AppTheme.successColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toplam Çalışma Süresi',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryColor),
              ),
              const SizedBox(height: 4),
              Text(
                '$hours saat $minutes dakika',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
