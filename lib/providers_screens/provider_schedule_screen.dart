import 'package:flutter/material.dart';

class ProviderScheduleScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ProviderScheduleScreen({super.key, required this.onBack});

  @override
  State<ProviderScheduleScreen> createState() => _ProviderScheduleScreenState();
}

class _ProviderScheduleScreenState extends State<ProviderScheduleScreen> {
  final List<String> _weekDays = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final Set<String> _selectedDays = {'Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'};
  
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);

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
        child: Column(
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
              onTap: () {
                 FocusScope.of(context).unfocus();
                 if (!mounted) return;
                 widget.onBack();
              },
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF6950F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Save Schedule',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
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
