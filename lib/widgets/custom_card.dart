import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

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
        shadowColor: AppTheme.primaryColor.withOpacity(0.1),
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

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarih ve Action Butonları
          Row(
            children: [
              Expanded(
                child: Text(
                  date,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor),
                ),
              ),
              if (onEdit != null || onDelete != null) ...[
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit, color: AppTheme.primaryColor, size: 20),
                    tooltip: 'Düzenle',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete, color: AppTheme.errorColor, size: 20),
                    tooltip: 'Sil',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Giriş ve Çıkış Saatleri
          Row(
            children: [
              Expanded(
                child: _TimeInfo(
                  label: 'Giriş',
                  time: checkInTime,
                  color: AppTheme.checkInColor,
                  icon: Icons.login,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TimeInfo(
                  label: 'Çıkış',
                  time: checkOutTime,
                  color: AppTheme.checkOutColor,
                  icon: Icons.logout,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: AppTheme.textLightColor),
          const SizedBox(height: 8),

          // Toplam Süre
          Row(
            children: [
              Icon(Icons.access_time, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Toplam: $workDuration',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
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

class _TimeInfo extends StatelessWidget {
  final String label;
  final String time;
  final Color color;
  final IconData icon;

  const _TimeInfo({
    required this.label,
    required this.time,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
