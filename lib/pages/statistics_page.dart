import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/atoms/filter_info_widget.dart';
import '../widgets/organisms/check_in_times_chart_widget.dart';
import '../widgets/organisms/distribution_chart_widget.dart';
import '../widgets/organisms/filter_bottom_sheet_widget.dart';
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
  DateTime? _startDate;
  DateTime? _endDate;
  bool _lastUsedMonthMode = false;
  Set<int> _lastSelectedMonths = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startDate = null;
    _endDate = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dateFilterProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      // Görünüm türünü koruyarak sadece seçimleri temizle
      _lastSelectedMonths.clear();
      // _lastUsedMonthMode değiştirme - mevcut görünümde kal
    });
    ref.read(dateFilterProvider.notifier).state = null;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        initialStartDate: _startDate,
        initialEndDate: _endDate,
        initialMonthMode: _lastUsedMonthMode,
        initialSelectedMonths: _lastSelectedMonths,
        onDateRangeChanged: (start, end) {
          setState(() {
            _startDate = start;
            _endDate = end;
          });
          if (start != null && end != null) {
            ref.read(dateFilterProvider.notifier).state = DateRange(
              startDate: start,
              endDate: end,
            );
          } else {
            ref.read(dateFilterProvider.notifier).state = null;
          }
        },
        onStateChanged: (isMonthMode, selectedMonths) {
          setState(() {
            _lastUsedMonthMode = isMonthMode;
            _lastSelectedMonths = selectedMonths;
          });
        },
        onClear: _clearFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statistics = ref.watch(statisticsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('İstatistikler'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              (_startDate != null && _endDate != null) ? Icons.filter_alt : Icons.tune,
              color: (_startDate != null && _endDate != null)
                  ? AppTheme.primaryColor
                  : null,
            ),
            onPressed: _showFilterBottomSheet,
            tooltip: (_startDate != null && _endDate != null)
                ? 'Filtre Aktif'
                : 'Filtrele',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Çalışma Saatleri'),
            Tab(text: 'Giriş Saatleri'),
            Tab(text: 'Dağılım'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filtre bilgisi
          FilterInfoWidget(
            showAllTime: (_startDate == null && _endDate == null),
            startDate: _startDate,
            endDate: _endDate,
          ),

          // Özet kartı
          StatisticsSummaryWidget(statistics: statistics),

          // Grafikler
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                WorkHoursChartWidget(statistics: statistics),
                CheckInTimesChartWidget(statistics: statistics),
                DistributionChartWidget(statistics: statistics),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
