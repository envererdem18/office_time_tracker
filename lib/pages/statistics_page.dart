import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/atoms/filter_info_widget.dart';
import '../widgets/organisms/check_in_times_chart_widget.dart';
import '../widgets/organisms/commute_times_chart_widget.dart';
import '../widgets/organisms/distribution_chart_widget.dart';
import '../widgets/organisms/filter_bottom_sheet_widget.dart';
import '../widgets/organisms/late_overtime_chart_widget.dart';
import '../widgets/organisms/statistics_summary_widget.dart';
import '../widgets/organisms/work_hours_chart_widget.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _clearFilter() {
    ref.read(filterStateProvider.notifier).state = ref.read(filterStateProvider).clear();
  }

  void _showFilterBottomSheet() {
    final currentFilter = ref.read(filterStateProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        initialStartDate: currentFilter.startDate,
        initialEndDate: currentFilter.endDate,
        initialMonthMode: currentFilter.isMonthMode,
        initialSelectedMonths: currentFilter.selectedMonths,
        onDateRangeChanged: (start, end) {
          ref.read(filterStateProvider.notifier).state = ref
              .read(filterStateProvider)
              .copyWith(startDate: () => start, endDate: () => end);
        },
        onStateChanged: (isMonthMode, selectedMonths) {
          ref.read(filterStateProvider.notifier).state = ref
              .read(filterStateProvider)
              .copyWith(isMonthMode: isMonthMode, selectedMonths: selectedMonths);
        },
        onClear: _clearFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statistics = ref.watch(statisticsProvider);
    final filterState = ref.watch(filterStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('İstatistikler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              filterState.hasFilter ? Icons.filter_alt : Icons.tune,
              color: filterState.hasFilter ? AppTheme.primaryColor : null,
            ),
            onPressed: _showFilterBottomSheet,
            tooltip: filterState.hasFilter ? 'Filtre Aktif' : 'Filtrele',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          dividerColor: Colors.transparent,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Çalışma Saatleri'),
            Tab(text: 'Giriş Saatleri'),
            Tab(text: 'Dağılım'),
            Tab(text: 'Geç Kalma & Fazla Mesai'),
            Tab(text: 'Yol Süreleri'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Filtre bilgisi
            FilterInfoWidget(
              showAllTime: !filterState.hasFilter,
              startDate: filterState.startDate,
              endDate: filterState.endDate,
            ),

            // Özet kartı
            StatisticsSummaryWidget(statistics: statistics),

            // Grafikler - TabBarView ile swipe desteği
            SizedBox(
              height: 1000,
              child: TabBarView(
                controller: _tabController,
                children: [
                  WorkHoursChartWidget(statistics: statistics),
                  CheckInTimesChartWidget(statistics: statistics),
                  DistributionChartWidget(statistics: statistics),
                  LateOvertimeChartWidget(statistics: statistics),
                  CommuteTimesChartWidget(statistics: statistics),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
