import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class InfoCardWidget extends StatelessWidget {
  const InfoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Değişiklikleriniz otomatik olarak kaydedilir. Gelecek tarih veya saatler seçilemez. Sayfadan çıktığınızda son değişiklikler de kaydedilecektir.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.primaryColor, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
