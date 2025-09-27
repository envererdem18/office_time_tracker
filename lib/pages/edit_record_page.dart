import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/check_in_out.dart';
import '../providers/database_provider.dart';
import '../theme/app_theme.dart';

class EditRecordPage extends ConsumerStatefulWidget {
  final CheckInOut record;

  const EditRecordPage({super.key, required this.record});

  @override
  ConsumerState<EditRecordPage> createState() => _EditRecordPageState();
}

class _EditRecordPageState extends ConsumerState<EditRecordPage> {
  late TimeOfDay? _checkInTime;
  late TimeOfDay? _checkOutTime;
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

  // Seçilen zamanın gelecekte olup olmadığını kontrol et
  bool _isTimeInFuture(TimeOfDay selectedTime) {
    final now = DateTime.now();
    final recordDate = widget.record.date;

    // Eğer kayıt tarihi bugün değilse, gelecek kontrol etmeye gerek yok
    if (!_isSameDay(recordDate, now)) {
      return false;
    }

    // Bugünkü tarih için seçilen zamanı DateTime'a çevir
    final selectedDateTime = DateTime(
      recordDate.year,
      recordDate.month,
      recordDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    return selectedDateTime.isAfter(now);
  }

  // İki tarihin aynı gün olup olmadığını kontrol et
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Gelecek zaman seçimi için uyarı göster
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
      // Gelecek zaman kontrolü
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
      // Gelecek zaman kontrolü
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

  void _clearCheckInTime() {
    setState(() {
      _checkInTime = null;
      _hasChanges = true;
    });
    _scheduleAutoSave();
  }

  void _clearCheckOutTime() {
    setState(() {
      _checkOutTime = null;
      _hasChanges = true;
    });
    _scheduleAutoSave();
  }

  Future<void> _saveChanges({bool showSnackBar = true}) async {
    if (!_hasChanges) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Yeni DateTime objelerini oluştur
      DateTime? newCheckInTime;
      DateTime? newCheckOutTime;

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

      // Güncellenmiş kaydı oluştur
      final updatedRecord = CheckInOut(
        date: widget.record.date,
        checkInTime: newCheckInTime,
        checkOutTime: newCheckOutTime,
      );

      // Veritabanını güncelle
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

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      await _saveChanges(showSnackBar: false);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
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
              _buildDateCard(),

              const SizedBox(height: 24),

              // Giriş saati kartı
              _buildTimeCard(
                title: 'Giriş Saati',
                time: _checkInTime,
                onTap: _selectCheckInTime,
                onClear: _clearCheckInTime,
                color: AppTheme.checkInColor,
                icon: Icons.login,
              ),

              const SizedBox(height: 16),

              // Çıkış saati kartı
              _buildTimeCard(
                title: 'Çıkış Saati',
                time: _checkOutTime,
                onTap: _selectCheckOutTime,
                onClear: _clearCheckOutTime,
                color: AppTheme.checkOutColor,
                icon: Icons.logout,
              ),

              const SizedBox(height: 24),

              // Çalışma süresi önizlemesi
              if (_checkInTime != null && _checkOutTime != null) _buildWorkDurationCard(),

              const SizedBox(height: 32),

              // Bilgilendirme kartı
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.calendar_today, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Düzenlenen Tarih',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryColor),
              ),
              const SizedBox(height: 4),
              Text(
                widget.record.dateString,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  Widget _buildTimeCard({
    required String title,
    required TimeOfDay? time,
    required VoidCallback onTap,
    required VoidCallback onClear,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time != null ? time.format(context) : 'Seçiniz',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: time != null ? color : AppTheme.textLightColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (time != null)
                  IconButton(
                    onPressed: onClear,
                    icon: Icon(Icons.clear, color: AppTheme.errorColor),
                    tooltip: 'Temizle',
                  )
                else
                  Icon(Icons.touch_app, color: AppTheme.textLightColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkDurationCard() {
    final checkIn = DateTime(2000, 1, 1, _checkInTime!.hour, _checkInTime!.minute);
    final checkOut = DateTime(2000, 1, 1, _checkOutTime!.hour, _checkOutTime!.minute);
    final duration = checkOut.difference(checkIn);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.schedule, color: AppTheme.successColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toplam Çalışma Süresi',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryColor),
              ),
              const SizedBox(height: 4),
              Text(
                '$hours saat $minutes dakika',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Değişiklikleriniz otomatik olarak kaydedilir. Gelecek tarih veya saatler seçilemez. Sayfadan çıktığınızda son değişiklikler de kaydedilecektir.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.primaryColor, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
