import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderScheduleScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ProviderScheduleScreen({super.key, required this.onBack});

  @override
  State<ProviderScheduleScreen> createState() => _ProviderScheduleScreenState();
}

class _ProviderScheduleScreenState extends State<ProviderScheduleScreen> {
  final List<String> _weekDays = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final Set<String> _selectedDays = {'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'};

  static const Map<String, int> _dayToWeekday = {
    'Sun': 0,
    'Mon': 1,
    'Tue': 2,
    'Wed': 3,
    'Thu': 4,
    'Fri': 5,
    'Sat': 6,
  };

  static const Map<int, String> _weekdayToDay = {
    0: 'Sun',
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
  };

  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 19, minute: 0);
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    try {
      final row = await client
          .from('provider_profiles')
          .select('working_days, work_start_time, work_end_time')
          .eq('user_id', userId)
          .maybeSingle();

      // Provider rows are created in the DB trigger; this ensures defaults
      // still get applied for any legacy rows with null values.
      if (row == null) {
        throw const AuthException('Provider profile not found.');
      }

      if (row['working_days'] == null ||
          row['work_start_time'] == null ||
          row['work_end_time'] == null) {
        await client.from('provider_profiles').update({
          'working_days': const [6, 0, 1, 2, 3, 4],
          'work_start_time': '08:00:00',
          'work_end_time': '19:00:00',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId);
      }

      final freshRow = await client
          .from('provider_profiles')
          .select('working_days, work_start_time, work_end_time')
          .eq('user_id', userId)
          .single();

      final dbDays =
          (freshRow['working_days'] as List<dynamic>? ?? const <dynamic>[])
              .map((e) => e as int)
              .toSet();
      final activeDays = dbDays
          .map((weekday) => _weekdayToDay[weekday])
          .whereType<String>()
          .toSet();

      final start = _parseDbTime(freshRow['work_start_time'] as String?);
      final end = _parseDbTime(freshRow['work_end_time'] as String?);

      if (!mounted) return;
      setState(() {
        _selectedDays
          ..clear()
          ..addAll(activeDays);
        _startTime = start ?? const TimeOfDay(hour: 8, minute: 0);
        _endTime = end ?? const TimeOfDay(hour: 19, minute: 0);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load schedule.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  TimeOfDay? _parseDbTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _toDbTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  Future<void> _saveSchedule() async {
    if (_isSaving) return;
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      final start = _toDbTime(_startTime);
      final end = _toDbTime(_endTime);
      final selectedWeekdays = _selectedDays
          .map((day) => _dayToWeekday[day])
          .whereType<int>()
          .toList()
        ..sort();

      await client.from('provider_profiles').update({
        'working_days': selectedWeekdays,
        'work_start_time': start,
        'work_end_time': end,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule updated.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save schedule.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart ? _startTime : _endTime;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6950F4),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && mounted) {
      setState(() {
        if (isStart) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
            if (!mounted) return;
            widget.onBack();
          },
          child: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Working Schedule',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, color: Colors.black87, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Days',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select the days you are available to take bookings.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _weekDays.map((day) {
                      final isSelected = _selectedDays.contains(day);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedDays.remove(day);
                            } else {
                              _selectedDays.add(day);
                            }
                          });
                        },
                        child: Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6950F4).withValues(alpha: 0.1) : Colors.white,
                            border: Border.all(color: isSelected ? const Color(0xFF6950F4) : Colors.black12, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            day,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: isSelected ? const Color(0xFF6950F4) : Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Active Hours',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Set your standard working hours for active days.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePickerBlock(
                          label: 'Opening Time',
                          time: _startTime,
                          onTap: () => _selectTime(context, true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTimePickerBlock(
                          label: 'Closing Time',
                          time: _endTime,
                          onTap: () => _selectTime(context, false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _isSaving
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            _saveSchedule();
                          },
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _isSaving
                            ? const Color(0xFF6950F4).withValues(alpha: 0.5)
                            : const Color(0xFF6950F4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _isSaving ? 'Saving...' : 'Save Schedule',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTimePickerBlock({required String label, required TimeOfDay time, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Icon(Icons.access_time_rounded, color: Color(0xFF6950F4), size: 20),
              ],
            )
          ],
        ),
      ),
    );
  }
}
