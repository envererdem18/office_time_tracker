import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class DemoWarningWidget extends StatelessWidget {
  const DemoWarningWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.warningColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bu demo sayfasıdır. Veriler gerçek veritabanına kaydedilmez.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.warningColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
