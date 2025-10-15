import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class DetailRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData? iconData;
  final Color? iconColor;

  const DetailRowWidget({
    super.key,
    required this.label,
    required this.value,
    this.iconData,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (iconData != null) ...[
          Icon(iconData, size: 16, color: iconColor ?? AppTheme.primaryColor),
          const SizedBox(width: 4),
        ],
        SizedBox(
          width: iconData != null ? 76 : 80,
          child: Text(
            '$label:',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryColor),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
