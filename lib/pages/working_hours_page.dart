import 'package:flutter/material.dart';

import '../models/working_hours.dart' as model;
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class WorkingHoursPage extends StatefulWidget {
  const WorkingHoursPage({super.key});

  @override
  State<WorkingHoursPage> createState() => _WorkingHoursPageState();
}

class _WorkingHoursPageState extends State<WorkingHoursPage> {
  final DatabaseService _databaseService = DatabaseService();
  final Map<int, model.WorkingHours> _workingHoursMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkingHours();
  }

  Future<void> _loadWorkingHours() async {
    setState(() {
      _isLoading = true;
    });

    final workingHours = _databaseService.getAllWorkingHours();

    // Tüm günler için varsayılan değerler oluştur
    for (var i = 1; i <= 7; i++) {
      if (workingHours.containsKey(i)) {
        _workingHoursMap[i] = workingHours[i]!;
      } else {
        _workingHoursMap[i] = model.WorkingHours(weekday: i);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveWorkingHours(model.WorkingHours workingHours) async {
    await _databaseService.saveWorkingHours(workingHours);
  }

  Future<void> _selectTime(BuildContext context, int weekday, bool isStartTime) async {
    final currentWorkingHours = _workingHoursMap[weekday]!;
    final initialTime = isStartTime
        ? currentWorkingHours.startTime?.toFlutter()
        : currentWorkingHours.endTime?.toFlutter();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          currentWorkingHours.startTime = model.TimeOfDay.fromFlutter(picked);
        } else {
          currentWorkingHours.endTime = model.TimeOfDay.fromFlutter(picked);
        }
      });

      // Otomatik kaydet
      await _saveWorkingHours(currentWorkingHours);
    }
  }

  Future<void> _clearTime(int weekday, bool isStartTime) async {
    final currentWorkingHours = _workingHoursMap[weekday]!;

    setState(() {
      if (isStartTime) {
        currentWorkingHours.startTime = null;
      } else {
        currentWorkingHours.endTime = null;
      }
    });

    // Otomatik kaydet
    await _saveWorkingHours(currentWorkingHours);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Mesai Saatlerim'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Haftalık mesai saatlerinizi belirleyin. Bu saatler, istatistiklerde geç kalma ve fazla mesai hesaplamalarında kullanılacaktır.',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
                  ),
                ),
                ..._workingHoursMap.entries.map((entry) {
                  return _buildWorkingHoursCard(entry.key, entry.value);
                }),
                const SizedBox(height: 80),
              ],
            ),
    );
  }

  Widget _buildWorkingHoursCard(int weekday, model.WorkingHours workingHours) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workingHours.weekdayName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimeSelector(
                    label: 'Başlangıç',
                    time: workingHours.startTimeString,
                    onTap: () => _selectTime(context, weekday, true),
                    onClear: workingHours.startTime != null
                        ? () => _clearTime(weekday, true)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeSelector(
                    label: 'Bitiş',
                    time: workingHours.endTimeString,
                    onTap: () => _selectTime(context, weekday, false),
                    onClear: workingHours.endTime != null
                        ? () => _clearTime(weekday, false)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String time,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: time == 'Yok'
                        ? AppTheme.textSecondaryColor
                        : AppTheme.textPrimaryColor,
                  ),
                ),
                if (onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppTheme.textSecondaryColor,
                    ),
                  )
                else
                  const Icon(Icons.access_time, size: 18, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
