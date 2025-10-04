import 'package:flutter/material.dart';

import '../../models/check_in_out.dart';
import '../../theme/app_theme.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final CheckInOut record;
  final VoidCallback onConfirm;

  const DeleteConfirmDialog({super.key, required this.record, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning, color: AppTheme.errorColor),
          const SizedBox(width: 8),
          Text(
            'Kayıt Sil',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.errorColor),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bu kaydı silmek istediğinizden emin misiniz?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.dateString,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 4),
                Text(
                  'Giriş: ${record.checkInTimeString} • Çıkış: ${record.checkOutTimeString}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bu işlem geri alınamaz.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.errorColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Sil'),
        ),
      ],
    );
  }
}
