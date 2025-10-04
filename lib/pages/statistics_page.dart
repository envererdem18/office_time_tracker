import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/atoms/filter_info_widget.dart';
import '../widgets/organisms/check_in_times_chart_widget.dart';
import '../widgets/organisms/distribution_chart_widget.dart';
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
  bool _showAllTime = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dateFilterProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _showAllTime = false;
      });
      ref.read(dateFilterProvider.notifier).state = DateRange(
        startDate: picked.start,
        endDate: picked.end,
      );
    }
  }

  void _showAllTimeData() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _showAllTime = true;
    });
    ref.read(dateFilterProvider.notifier).state = null;
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value == 'range') {
                _selectDateRange();
              } else if (value == 'all') {
                _showAllTimeData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'range',
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 20),
                    SizedBox(width: 8),
                    Text('Tarih Aralığı Seç'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 20),
                    SizedBox(width: 8),
                    Text('Tüm Zamanlar'),
                  ],
                ),
              ),
            ],
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
            showAllTime: _showAllTime,
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
