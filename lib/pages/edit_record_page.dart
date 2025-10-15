import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/check_in_out.dart';
import '../providers/database_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/molecules/date_card_widget.dart';
import '../widgets/molecules/info_card_widget.dart';
import '../widgets/molecules/time_card_widget.dart';
import '../widgets/molecules/work_duration_card_widget.dart';

class EditRecordPage extends ConsumerStatefulWidget {
  final CheckInOut record;

  const EditRecordPage({super.key, required this.record});

  @override
  ConsumerState<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends ConsumerState<EditRecordPage> {
  late TimeOfDay? _checkInTime;
  late TimeOfDay? _checkOutTime;
  late TimeOfDay? _commuteDepartureTime;
  late TimeOfDay? _returnArrivalTime;
  Timer? _saveTimer;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _checkInTime = widget.record.checkInTime != null
        ? TimeOfDay.fromDateTime(widget.record.checkInTime!)
        : null;
    _checkOutTime = widget.record.checkOutTime != null
        ? TimeOfDay.fromDateTime(widget.record.checkOutTime!)
        : null;
    _commuteDepartureTime = widget.record.commuteDepartureTime != null
        ? TimeOfDay.fromDateTime(widget.record.commuteDepartureTime!)
        : null;
    _returnArrivalTime = widget.record.returnArrivalTime != null
        ? TimeOfDay.fromDateTime(widget.record.returnArrivalTime!)
        : null;
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  void _scheduleAutoSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_hasChanges && mounted) {
        _saveChanges(showSnackBar: false);
      }
    });
  }

  bool _isTimeInFuture(TimeOfDay selectedTime) {
    final now = DateTime.now();
    final recordDate = widget.record.date;

    if (!_isSameDay(recordDate, now)) {
      return false;
    }

    final selectedDateTime = DateTime(
      recordDate.year,
      recordDate.month,
      recordDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    return selectedDateTime.isAfter(now);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showFutureTimeWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gelecek bir saat seçemezsiniz!'),
        backgroundColor: AppTheme.errorColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _selectCheckInTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _checkInTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.checkInColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (_isTimeInFuture(picked)) {
        _showFutureTimeWarning();
        return;
      }

      setState(() {
        _checkInTime = picked;
        _hasChanges = true;
      });
      _scheduleAutoSave();
    }
  }

  Future<void> _selectCheckOutTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _checkOutTime ?? const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppTheme.checkOutColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (_isTimeInFuture(picked)) {
        _showFutureTimeWarning();
        return;
      }

      setState(() {
        _checkOutTime = picked;
        _hasChanges = true;
      });
      _scheduleAutoSave();
    }
  }

  Future<void> _selectCommuteDepartureTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _commuteDepartureTime ?? const TimeOfDay(hour: 8, minute: 0),
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
      if (_isTimeInFuture(picked)) {
        _showFutureTimeWarning();
        return;
      }

      setState(() {
        _commuteDepartureTime = picked;
        _hasChanges = true;
      });
      _scheduleAutoSave();
    }
  }

  Future<void> _selectReturnArrivalTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _returnArrivalTime ?? const TimeOfDay(hour: 19, minute: 0),
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
      if (_isTimeInFuture(picked)) {
        _showFutureTimeWarning();
        return;
      }

      setState(() {
        _returnArrivalTime = picked;
        _hasChanges = true;
      });
      _scheduleAutoSave();
    }
  }

  Future<void> _saveChanges({bool showSnackBar = true}) async {
    if (!_hasChanges) return;

    setState(() {
      _isLoading = true;
    });

    try {
      DateTime? newCheckInTime;
      DateTime? newCheckOutTime;
      DateTime? newCommuteDepartureTime;
      DateTime? newReturnArrivalTime;

      if (_checkInTime != null) {
        newCheckInTime = DateTime(
          widget.record.date.year,
          widget.record.date.month,
          widget.record.date.day,
          _checkInTime!.hour,
          _checkInTime!.minute,
        );
      }

      if (_checkOutTime != null) {
        newCheckOutTime = DateTime(
          widget.record.date.year,
          widget.record.date.month,
          widget.record.date.day,
          _checkOutTime!.hour,
          _checkOutTime!.minute,
        );
      }

      if (_commuteDepartureTime != null) {
        newCommuteDepartureTime = DateTime(
          widget.record.date.year,
          widget.record.date.month,
          widget.record.date.day,
          _commuteDepartureTime!.hour,
          _commuteDepartureTime!.minute,
        );
      }

      if (_returnArrivalTime != null) {
        newReturnArrivalTime = DateTime(
          widget.record.date.year,
          widget.record.date.month,
          widget.record.date.day,
          _returnArrivalTime!.hour,
          _returnArrivalTime!.minute,
        );
      }

      final updatedRecord = CheckInOut(
        date: widget.record.date,
        checkInTime: newCheckInTime,
        checkOutTime: newCheckOutTime,
        commuteDepartureTime: newCommuteDepartureTime,
        returnArrivalTime: newReturnArrivalTime,
      );

      final updateAction = ref.read(updateRecordActionProvider);
      await updateAction(updatedRecord);

      setState(() {
        _hasChanges = false;
      });

      if (mounted && showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarıyla güncellendi!'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: AppTheme.errorColor),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onPopInvoked(bool didPop, dynamic result) async {
    if (_hasChanges && !didPop) {
      await _saveChanges(showSnackBar: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commuteTrackingEnabled = ref.watch(commuteTrackingEnabledProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Kaydı Düzenle'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_hasChanges) {
                await _saveChanges(showSnackBar: false);
              }
              if (context.mounted) {
                context.pop();
              }
            },
          ),
          actions: [
            if (_hasChanges)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryColor,
                        ),
                      )
                    else
                      Icon(Icons.auto_awesome, size: 14, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      _isLoading ? 'Kaydediliyor...' : 'Otomatik kayıt',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarih bilgisi kartı
              DateCardWidget(record: widget.record),

              const SizedBox(height: 24),

              // Yol bilgileri (eğer aktifse)
              if (commuteTrackingEnabled) ...[
                Text(
                  'Yol Bilgileri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                TimeCardWidget(
                  title: 'Yola Çıkış Saati',
                  time: _commuteDepartureTime,
                  onTap: _selectCommuteDepartureTime,
                  color: AppTheme.primaryColor,
                  icon: Icons.directions_walk,
                ),
                const SizedBox(height: 16),
              ],

              // Ofis bilgileri
              Text(
                'Ofis Bilgileri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),

              // Giriş saati kartı
              TimeCardWidget(
                title: 'Giriş Saati',
                time: _checkInTime,
                onTap: _selectCheckInTime,
                color: AppTheme.checkInColor,
                icon: Icons.login,
              ),

              const SizedBox(height: 16),

              // Çıkış saati kartı
              TimeCardWidget(
                title: 'Çıkış Saati',
                time: _checkOutTime,
                onTap: _selectCheckOutTime,
                color: AppTheme.checkOutColor,
                icon: Icons.logout,
              ),

              const SizedBox(height: 16),

              // Çalışma süresi önizlemesi
              if (_checkInTime != null && _checkOutTime != null)
                WorkDurationCardWidget(
                  checkInTime: _checkInTime!,
                  checkOutTime: _checkOutTime!,
                ),

              // Dönüş yolu bilgileri (eğer aktifse)
              if (commuteTrackingEnabled) ...[
                const SizedBox(height: 24),
                Text(
                  'Dönüş Yolu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                TimeCardWidget(
                  title: 'Eve Varış Saati',
                  time: _returnArrivalTime,
                  onTap: _selectReturnArrivalTime,
                  color: AppTheme.primaryColor,
                  icon: Icons.home,
                ),
              ],

              const SizedBox(height: 32),

              // Bilgilendirme kartı
              const InfoCardWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
