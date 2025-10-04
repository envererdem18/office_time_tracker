import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class TodayStatusCardWidget extends StatelessWidget {
  final dynamic todayRecord;
  final bool isDemo;

  const TodayStatusCardWidget({
    super.key,
    required this.todayRecord,
    this.isDemo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
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
          Row(
            children: [
              Text(
                isDemo ? 'Demo Durum' : 'Bugünkü Durum',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor),
              ),
              if (isDemo) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DEMO',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  context,
                  'Giriş',
                  todayRecord.checkInTimeString,
                  AppTheme.checkInColor,
                  Icons.login,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeInfo(
                  context,
                  'Çıkış',
                  todayRecord.checkOutTimeString,
                  AppTheme.checkOutColor,
                  Icons.logout,
                ),
              ),
            ],
          ),
          if (todayRecord.workDuration != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Toplam: ${todayRecord.workDurationString}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfo(
    BuildContext context,
    String label,
    String time,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
