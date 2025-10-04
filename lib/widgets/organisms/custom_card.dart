import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: backgroundColor ?? AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: elevation ?? 2,
        shadowColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}

// Özel CheckInOut kartı
class CheckInOutCard extends StatelessWidget {
  final String date;
  final String checkInTime;
  final String checkOutTime;
  final String workDuration;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CheckInOutCard({
    super.key,
    required this.date,
    required this.checkInTime,
    required this.checkOutTime,
    required this.workDuration,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  // Tarih string'ini parse etmek için yardımcı method
  Map<String, String> _parseDateString(String dateStr) {
    try {
      // Format: "15 Ocak 2024, Pazartesi"
      final parts = dateStr.split(' ');
      if (parts.length >= 2) {
        final day = parts[0];
        final month = parts[1];
        return {'day': day, 'month': month.length > 3 ? month.substring(0, 3) : month};
      }
    } catch (e) {
      // Hata durumunda varsayılan değerler
    }
    return {'day': '--', 'month': '--'};
  }

  @override
  Widget build(BuildContext context) {
    final dateInfo = _parseDateString(date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Tarih Bölümü
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dateInfo['day']!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        dateInfo['month']!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Zaman Bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Giriş - Çıkış
                      Row(
                        children: [
                          Icon(Icons.login, size: 14, color: AppTheme.checkInColor),
                          const SizedBox(width: 4),
                          Text(
                            checkInTime,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.checkInColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.logout, size: 14, color: AppTheme.checkOutColor),
                          const SizedBox(width: 4),
                          Text(
                            checkOutTime,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.checkOutColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Toplam Süre
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: AppTheme.successColor),
                          const SizedBox(width: 4),
                          Text(
                            workDuration,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                if (onEdit != null || onDelete != null) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          onPressed: onEdit,
                          icon: Icon(
                            Icons.edit_outlined,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                          tooltip: 'Düzenle',
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      if (onDelete != null)
                        IconButton(
                          onPressed: onDelete,
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppTheme.errorColor,
                            size: 18,
                          ),
                          tooltip: 'Sil',
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
