import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/customer_dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingScheduleScreen extends StatefulWidget {
  final Map<String, dynamic>? serviceData;

  const BookingScheduleScreen({super.key, this.serviceData});

  @override
  State<BookingScheduleScreen> createState() => _BookingScheduleScreenState();
}

class _BookingScheduleScreenState extends State<BookingScheduleScreen> {
  int _selectedDateIndex = 0;
  int? _selectedTimeIndex;

  bool _isBootstrapping = true;
  bool _isLoadingSlots = false;
  bool _isSubmitting = false;

  String _serviceId = '';
  String _providerId = '';
  int _serviceDurationMinutes = 60;

  Set<int> _workingDays = const {0, 1, 2, 3, 4, 5, 6};
  TimeOfDay _workStart = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _workEnd = const TimeOfDay(hour: 19, minute: 0);

  List<Map<String, String>> _dates = <Map<String, String>>[];
  List<Map<String, dynamic>> _timeSlots = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _isBootstrapping = true);

    final serviceId = (widget.serviceData?['id'] as String?)?.trim() ?? '';
    var providerId =
        (widget.serviceData?['providerId'] as String?)?.trim() ?? '';
    final durationText =
        (widget.serviceData?['durationText'] as String?)?.trim() ?? '';

    _serviceId = serviceId;
    _providerId = providerId;
    _serviceDurationMinutes = _parseDurationMinutes(durationText);

    final client = Supabase.instance.client;

    try {
      if (_serviceId.isNotEmpty &&
          (_providerId.isEmpty || durationText.isEmpty)) {
        final row = await client
            .from('services')
            .select('provider_id, duration_text')
            .eq('id', _serviceId)
            .maybeSingle();
        if (row != null) {
          providerId = (row['provider_id'] as String?)?.trim() ?? providerId;
          final dbDuration = (row['duration_text'] as String?)?.trim() ?? '';
          _providerId = providerId;
          if (dbDuration.isNotEmpty) {
            _serviceDurationMinutes = _parseDurationMinutes(dbDuration);
          }
        }
      }

      if (_providerId.isNotEmpty) {
        await _loadProviderSchedule(_providerId);
      }

      _dates = _generateProviderDates();
      if (_dates.isNotEmpty) {
        _selectedDateIndex = 0;
        await _loadSlotsForSelectedDate();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load scheduling data.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBootstrapping = false);
      }
    }
  }

  Future<void> _loadProviderSchedule(String providerId) async {
    final client = Supabase.instance.client;
    final row = await client
        .from('provider_profiles')
        .select('working_days, work_start_time, work_end_time')
        .eq('user_id', providerId)
        .maybeSingle();

    if (row == null) {
      return;
    }

    final dbDays = (row['working_days'] as List<dynamic>? ?? const <dynamic>[])
        .map((e) => e as int)
        .toSet();
    final start = _parseDbTime(row['work_start_time'] as String?);
    final end = _parseDbTime(row['work_end_time'] as String?);

    _workingDays = dbDays.isEmpty ? _workingDays : dbDays;
    _workStart = start ?? _workStart;
    _workEnd = end ?? _workEnd;
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

  List<Map<String, String>> _generateProviderDates() {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dates = <Map<String, String>>[];

    for (int offset = 0; offset < 30 && dates.length < 7; offset++) {
      final date = now.add(Duration(days: offset));
      final dbWeekday =
          date.weekday % 7; // Dart Mon=1..Sun=7 -> DB Sun=0..Sat=6
      if (!_workingDays.contains(dbWeekday)) {
        continue;
      }

      final dayLabel = offset == 0 ? 'Today' : weekdays[date.weekday - 1];
      dates.add({
        'day': dayLabel,
        'date': date.day.toString(),
        'fullDate':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      });
    }

    return dates;
  }

  Future<void> _loadSlotsForSelectedDate() async {
    if (_dates.isEmpty || _providerId.isEmpty) {
      setState(() {
        _timeSlots = <Map<String, dynamic>>[];
        _selectedTimeIndex = null;
      });
      return;
    }

    final selectedDate = _dates[_selectedDateIndex]['fullDate'] ?? '';
    if (selectedDate.isEmpty) {
      return;
    }

    setState(() => _isLoadingSlots = true);

    final client = Supabase.instance.client;
    try {
      final bookingRows = await client
          .from('bookings')
          .select('booking_status, time_slot_text, scheduled_at')
          .eq('provider_id', _providerId)
          .eq('booking_date', selectedDate)
          .inFilter('booking_status', const [
        'pending',
        'accepted',
        'in_progress'
      ]).order('scheduled_at', ascending: true);

      final bookedIntervals = List<Map<String, dynamic>>.from(bookingRows)
          .map(_extractBookedInterval)
          .whereType<_SlotInterval>()
          .toList()
        ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

      final generatedSlots = _generateSlots(
        workStartMinutes: _toMinutes(_workStart),
        workEndMinutes: _toMinutes(_workEnd),
        durationMinutes: _serviceDurationMinutes,
        booked: bookedIntervals,
      );

      int? selectedIndex;
      for (var i = 0; i < generatedSlots.length; i++) {
        if (!(generatedSlots[i]['isBooked'] as bool)) {
          selectedIndex = i;
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        _timeSlots = generatedSlots;
        _selectedTimeIndex = selectedIndex;
        _isLoadingSlots = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingSlots = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load available slots.')),
      );
    }
  }

  _SlotInterval? _extractBookedInterval(Map<String, dynamic> row) {
    final timeText = (row['time_slot_text'] as String?)?.trim() ?? '';
    final parsedRange = _parseTimeRange(timeText);

    int? startMinutes = parsedRange?.$1;
    int? endMinutes = parsedRange?.$2;

    final scheduledAtRaw = row['scheduled_at'] as String?;
    final scheduledAt =
        scheduledAtRaw == null ? null : DateTime.tryParse(scheduledAtRaw);
    if (startMinutes == null && scheduledAt != null) {
      startMinutes = scheduledAt.hour * 60 + scheduledAt.minute;
    }
    if (endMinutes == null && startMinutes != null) {
      endMinutes = startMinutes + 30;
    }

    if (startMinutes == null ||
        endMinutes == null ||
        endMinutes <= startMinutes) {
      return null;
    }

    return _SlotInterval(
        startMinutes: startMinutes, endMinutes: endMinutes, isBooked: true);
  }

  List<Map<String, dynamic>> _generateSlots({
    required int workStartMinutes,
    required int workEndMinutes,
    required int durationMinutes,
    required List<_SlotInterval> booked,
  }) {
    final available = <_SlotInterval>[];
    var cursor = workStartMinutes;

    for (final interval in booked) {
      final blockedStart =
          interval.startMinutes.clamp(workStartMinutes, workEndMinutes).toInt();
      final blockedEnd =
          interval.endMinutes.clamp(workStartMinutes, workEndMinutes).toInt();
      if (blockedEnd <= cursor) {
        continue;
      }

      final gapEnd = min(blockedStart, workEndMinutes);
      while (cursor + durationMinutes <= gapEnd) {
        available.add(
          _SlotInterval(
            startMinutes: cursor,
            endMinutes: cursor + durationMinutes,
            isBooked: false,
          ),
        );
        cursor += durationMinutes;
      }

      cursor = max(cursor, blockedEnd);
      if (cursor >= workEndMinutes) break;
    }

    while (cursor + durationMinutes <= workEndMinutes) {
      available.add(
        _SlotInterval(
          startMinutes: cursor,
          endMinutes: cursor + durationMinutes,
          isBooked: false,
        ),
      );
      cursor += durationMinutes;
    }

    final bookedClamped = booked
        .map(
          (e) => _SlotInterval(
            startMinutes:
                e.startMinutes.clamp(workStartMinutes, workEndMinutes).toInt(),
            endMinutes:
                e.endMinutes.clamp(workStartMinutes, workEndMinutes).toInt(),
            isBooked: true,
          ),
        )
        .where((e) => e.endMinutes > e.startMinutes)
        .toList();

    final all = <_SlotInterval>[
      ...available,
      ...bookedClamped,
    ]..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

    return all
        .map(
          (slot) => <String, dynamic>{
            'time':
                '${_formatTime(slot.startMinutes)} - ${_formatTime(slot.endMinutes)}',
            'isBooked': slot.isBooked,
            'startMinutes': slot.startMinutes,
            'endMinutes': slot.endMinutes,
          },
        )
        .toList();
  }

  (int, int)? _parseTimeRange(String text) {
    if (text.isEmpty) return null;
    final parts = text.split(RegExp(r'\s*[-–]\s*'));
    if (parts.length != 2) return null;

    final start = _parseSingleTime(parts[0]);
    final end = _parseSingleTime(parts[1]);
    if (start == null || end == null) return null;

    return (start, end);
  }

  int? _parseSingleTime(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    final match =
        RegExp(r'^(\d{1,2})(?::(\d{1,2}))?\s*([AaPp][Mm])?$').firstMatch(value);
    if (match == null) return null;

    var hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '0');
    final ampm = match.group(3)?.toLowerCase();
    if (hour == null || minute == null || minute < 0 || minute > 59) {
      return null;
    }

    if (ampm != null) {
      if (hour < 1 || hour > 12) {
        return null;
      }
      if (ampm == 'am') {
        hour = hour == 12 ? 0 : hour;
      } else {
        hour = hour == 12 ? 12 : hour + 12;
      }
    } else if (hour < 0 || hour > 23) {
      return null;
    }

    return hour * 60 + minute;
  }

  int _parseDurationMinutes(String raw) {
    final text = raw.toLowerCase().trim();
    if (text.isEmpty) return 60;

    final hourMatch = RegExp(r'(\d+)\s*(h|hr|hrs|hour|hours)').firstMatch(text);
    final minMatch =
        RegExp(r'(\d+)\s*(m|min|mins|minute|minutes)').firstMatch(text);
    final plainNumber = RegExp(r'^\d+$').firstMatch(text);

    int minutes = 0;
    if (hourMatch != null) {
      minutes += (int.tryParse(hourMatch.group(1) ?? '') ?? 0) * 60;
    }
    if (minMatch != null) {
      minutes += int.tryParse(minMatch.group(1) ?? '') ?? 0;
    }
    if (minutes == 0 && plainNumber != null) {
      minutes = int.tryParse(plainNumber.group(0) ?? '') ?? 60;
    }

    return minutes <= 0 ? 60 : minutes;
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  String _formatTime(int minutes) {
    final hh24 = (minutes ~/ 60) % 24;
    final mm = minutes % 60;
    final suffix = hh24 >= 12 ? 'PM' : 'AM';
    final hh12 = hh24 % 12 == 0 ? 12 : hh24 % 12;
    return '$hh12:${mm.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schedule Order',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: _isBootstrapping
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    _buildNoticeBanner(),
                    const SizedBox(height: 14),
                    _buildDateSelector(),
                    const SizedBox(height: 14),
                    _buildTimeSelector(),
                    const SizedBox(height: 24),
                    _buildConfirmButton(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNoticeBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDD8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFF9800).withValues(alpha: 0.5),
          width: 1.2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.thumb_up_alt_outlined,
              color: Color(0xFFEF9A9A),
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a Schedule Slot',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Slots are generated by service duration and provider availability.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Date',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.calendar_month_outlined,
                  color: Color(0xFFEF9A9A), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          if (_dates.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No available dates for this provider.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: List.generate(_dates.length, (index) {
                  final isSelected = _selectedDateIndex == index;
                  final date = _dates[index];
                  return GestureDetector(
                    onTap: () async {
                      if (_selectedDateIndex == index) return;
                      setState(() => _selectedDateIndex = index);
                      await _loadSlotsForSelectedDate();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 52,
                      height: 60,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFFE2DCFE) : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6950F4)
                              : const Color(0xFFE0E0E0),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            date['day'] ?? '',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF6950F4)
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date['date'] ?? '',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF6950F4)
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available slots ($_serviceDurationMinutes min each)',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingSlots)
            const Center(child: CircularProgressIndicator())
          else if (_timeSlots.isEmpty)
            const Text(
              'No slots available on this day.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.black54,
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.45,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final slot = _timeSlots[index];
                final isBooked = slot['isBooked'] as bool;
                final isSelected = _selectedTimeIndex == index;

                return GestureDetector(
                  onTap: isBooked
                      ? null
                      : () => setState(() => _selectedTimeIndex = index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isBooked
                          ? const Color(0xFFE4FAF3)
                          : isSelected
                              ? const Color(0xFFE2DCFE)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isBooked
                            ? const Color(0xFFB9EFE0)
                            : isSelected
                                ? const Color(0xFFB5A4F9)
                                : const Color(0xFFE0E0E0),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slot['time'] as String,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.2,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF6950F4)
                                : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isBooked) ...[
                          const SizedBox(height: 1),
                          const Text(
                            'Booked',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF7D9E94),
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    if (_selectedTimeIndex == null ||
        _selectedTimeIndex! >= _timeSlots.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an available time slot.')),
      );
      return;
    }

    final selectedSlot = _timeSlots[_selectedTimeIndex!];
    if ((selectedSlot['isBooked'] as bool)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This slot is already booked.')),
      );
      return;
    }

    final name = (widget.serviceData?['name'] as String?)?.trim() ?? '';
    final category = (widget.serviceData?['category'] as String?)?.trim() ?? '';
    final price = (widget.serviceData?['price'] ?? '').toString();
    final provider =
        (widget.serviceData?['providerName'] as String?)?.trim() ?? '';

    final selectedDateString = _dates[_selectedDateIndex]['fullDate'] ?? '';
    final selectedTimeString = selectedSlot['time'] as String? ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Service:', name),
            const SizedBox(height: 8),
            _buildDialogRow('Details:', category),
            const SizedBox(height: 8),
            _buildDialogRow('Provider:', provider),
            const SizedBox(height: 8),
            _buildDialogRow('Date:', selectedDateString),
            const SizedBox(height: 8),
            _buildDialogRow('Time:', selectedTimeString),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Cost:',
                  style: TextStyle(
                      fontFamily: 'Inter', fontWeight: FontWeight.w700),
                ),
                Text(
                  'BDT $price',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6950F4),
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () async {
                    Navigator.pop(ctx);
                    await _processBooking();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6950F4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Book',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processBooking() async {
    if (_selectedTimeIndex == null ||
        _selectedTimeIndex! >= _timeSlots.length) {
      return;
    }
    if (_serviceId.isEmpty || _providerId.isEmpty || _dates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service information is incomplete.')),
      );
      return;
    }

    final selectedSlot = _timeSlots[_selectedTimeIndex!];
    if (selectedSlot['isBooked'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This slot is already booked.')),
      );
      return;
    }

    final client = Supabase.instance.client;
    final customerId = client.auth.currentUser?.id;
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to continue.')),
      );
      return;
    }

    final selectedDate = _dates[_selectedDateIndex]['fullDate'] ?? '';
    if (selectedDate.isEmpty) {
      return;
    }

    final slotStartMinutes = selectedSlot['startMinutes'] as int;
    final slotEndMinutes = selectedSlot['endMinutes'] as int;
    final scheduledAt = DateTime.parse('${selectedDate}T00:00:00').add(
      Duration(minutes: slotStartMinutes),
    );

    final slotText = selectedSlot['time'] as String;
    final unitPrice = _parsePrice(widget.serviceData?['price']);

    setState(() => _isSubmitting = true);
    try {
      final dayBookings = await client
          .from('bookings')
          .select('time_slot_text, scheduled_at')
          .eq('provider_id', _providerId)
          .eq('booking_date', selectedDate)
          .inFilter(
              'booking_status', const ['pending', 'accepted', 'in_progress']);

      final hasConflict =
          List<Map<String, dynamic>>.from(dayBookings).any((row) {
        final interval = _extractBookedInterval(row);
        if (interval == null) return false;
        return slotStartMinutes < interval.endMinutes &&
            slotEndMinutes > interval.startMinutes;
      });

      if (hasConflict) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'This slot was just booked by someone else. Please choose another.'),
          ),
        );
        await _loadSlotsForSelectedDate();
        return;
      }

      final inserted = await client
          .from('bookings')
          .insert({
            'booking_code': _generateBookingCode(),
            'customer_id': customerId,
            'provider_id': _providerId,
            'service_id': _serviceId,
            'booking_date': selectedDate,
            'time_slot_text': slotText,
            'scheduled_at': scheduledAt.toIso8601String(),
            'quantity': 1,
            'unit_price': unitPrice,
            'total_amount': unitPrice,
            'payment_method': 'offline',
            'payment_status': 'unpaid',
            'booking_status': 'pending',
          })
          .select('id')
          .single();

      final bookingId = inserted['id'] as String?;
      if (bookingId != null && bookingId.isNotEmpty) {
        await client.from('booking_status_history').insert({
          'booking_id': bookingId,
          'status': 'pending',
          'changed_by': customerId,
          'note': 'Booking created by customer.',
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking confirmed successfully.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()),
          (route) => false,
        );
      });
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
      await _loadSlotsForSelectedDate();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not complete booking.')),
      );
      await _loadSlotsForSelectedDate();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _generateBookingCode() {
    final now = DateTime.now();
    final random = Random().nextInt(9000) + 1000;
    return 'BK-${now.millisecondsSinceEpoch}-$random';
  }

  double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
      return parsed ?? 0;
    }
    return 0;
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: (_selectedTimeIndex == null || _isSubmitting)
          ? null
          : _showConfirmationDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B5CF6),
        minimumSize: const Size(double.infinity, 46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        shadowColor: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
      ),
      child: Text(
        _isSubmitting ? 'Booking...' : 'Confirm Booking',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SlotInterval {
  const _SlotInterval({
    required this.startMinutes,
    required this.endMinutes,
    required this.isBooked,
  });

  final int startMinutes;
  final int endMinutes;
  final bool isBooked;
}
