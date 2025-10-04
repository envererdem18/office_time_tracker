import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class StatusMessageWidget extends StatelessWidget {
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final bool isDemo;

  const StatusMessageWidget({
    super.key,
    required this.hasCheckedIn,
    required this.hasCheckedOut,
    this.isDemo = false,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    Color color;
    IconData icon;

    if (!hasCheckedIn) {
      message = isDemo
          ? 'Demo: Giriş yapmak için yeşil butona basın'
          : 'Giriş yapmak için yeşil butona basın';
      color = AppTheme.checkInColor;
      icon = Icons.info_outline;
    } else if (!hasCheckedOut) {
      message = isDemo ? 'Demo: Çıkış yapmayı unutmayın!' : 'Çıkış yapmayı unutmayın!';
      color = AppTheme.warningColor;
      icon = Icons.warning_amber_outlined;
    } else {
      message = isDemo
          ? 'Demo: Günün kaydı tamamlandı. Sıfırla butonuna basarak tekrar deneyin!'
          : 'Günün kaydı tamamlandı. İyi günler!';
      color = AppTheme.successColor;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
