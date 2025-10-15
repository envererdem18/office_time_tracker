import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/month_chip_widget.dart';

class MonthGridWidget extends StatelessWidget {
  final Set<int> selectedMonths;
  final Function(int) onMonthTap;
  final VoidCallback? onShowAllTime;
  final bool showAllTimeButton;

  const MonthGridWidget({
    super.key,
    required this.selectedMonths,
    required this.onMonthTap,
    this.onShowAllTime,
    this.showAllTimeButton = true,
  });

  static const monthNames = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Ay seçimi grid'i
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = selectedMonths.contains(month);
                final monthName = monthNames[index];

                return MonthChipWidget(
                  monthName: monthName,
                  isSelected: isSelected,
                  onTap: () => onMonthTap(month),
                );
              },
            ),
          ),

          // Seçili aylar bilgisi
          if (selectedMonths.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Seçili Aylar (${selectedMonths.length})',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: selectedMonths.map((month) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          monthNames[month - 1],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Tüm Zamanlar butonu
          if (onShowAllTime != null && showAllTimeButton)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onShowAllTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.successColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.all_inclusive, color: AppTheme.successColor, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Tüm Zamanlar',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
