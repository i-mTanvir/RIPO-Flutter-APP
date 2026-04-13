import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/customer_dashboard_screen.dart';

class BookingScheduleScreen extends StatefulWidget {
  final Map<String, dynamic>? serviceData;

  const BookingScheduleScreen({super.key, this.serviceData});

  @override
  State<BookingScheduleScreen> createState() => _BookingScheduleScreenState();
}

class _BookingScheduleScreenState extends State<BookingScheduleScreen> {
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 5; // Default "3 PM - 4 PM"

  late final List<Map<String, String>> _dates;

  final List<Map<String, dynamic>> _timeSlots = [
    {'time': '10 AM - 11 AM', 'isBooked': true},
    {'time': '11 AM - 12 PM', 'isBooked': true},
    {'time': '12 PM - 1 PM', 'isBooked': true},
    {'time': '1 PM - 2 PM', 'isBooked': true},
    {'time': '2 PM - 3 PM', 'isBooked': false},
    {'time': '3 PM - 4 PM', 'isBooked': false},
    {'time': '4 PM - 5 PM', 'isBooked': false},
    {'time': '9 PM - 10 PM', 'isBooked': false},
  ];

  @override
  void initState() {
    super.initState();
    _dates = _generateDates();
  }

  List<Map<String, String>> _generateDates() {
    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<Map<String, String>> datesList = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 5; i++) {
       DateTime genDate = now.add(Duration(days: i));
       String dayName = i == 0 ? 'Today' : weekdays[genDate.weekday - 1];
       datesList.add({
         'day': dayName, 
         'date': genDate.day.toString(),
         'fullDate': '${genDate.year}-${genDate.month.toString().padLeft(2, '0')}-${genDate.day.toString().padLeft(2, '0')}'
       });
    }
    return datesList;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.5), width: 1.2, strokeAlign: BorderSide.strokeAlignOutside),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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
                  'Please select between our available time slots below for delivery of your order',
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
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Select Date',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.calendar_month_outlined, color: Color(0xFFEF9A9A), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: List.generate(_dates.length, (index) {
                final isSelected = _selectedDateIndex == index;
                final date = _dates[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedDateIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 44,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE2DCFE) : Colors.white,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6950F4) : const Color(0xFFE0E0E0),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date['day']!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF6950F4) : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date['date']!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected ? const Color(0xFF6950F4) : Colors.black87,
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
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'At What time should the service arrive?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 4.0,
            ),
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final slot = _timeSlots[index];
              final isBooked = slot['isBooked'] as bool;
              final isSelected = _selectedTimeIndex == index;

              return GestureDetector(
                onTap: isBooked ? null : () => setState(() => _selectedTimeIndex = index),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF6950F4) : Colors.black87,
                        ),
                      ),
                      if (isBooked) ...[
                        const SizedBox(height: 1),
                        const Text(
                          'Booked',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
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
    final name = widget.serviceData?['name'] ?? 'AC Cooling Problem';
    final category = widget.serviceData?['category'] ?? 'AC Repair';
    final price = widget.serviceData?['price']?.toString() ?? '500';
    
    final selectedDateString = _dates[_selectedDateIndex]['fullDate'];
    final selectedTimeString = _timeSlots[_selectedTimeIndex]['time'];

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
            _buildDialogRow('Provider:', 'Shaidul Islam'),
            const SizedBox(height: 8),
            _buildDialogRow('Date:', selectedDateString ?? ''),
            const SizedBox(height: 8),
            _buildDialogRow('Time:', selectedTimeString ?? ''),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Cost:',
                  style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
                ),
                Text(
                  '৳ $price',
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
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              _processBooking(); // Continue to success and dashboard
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6950F4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Book', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _processBooking() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Booking Confirmed Successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Navigate back to Dashboard resetting the stack
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()),
        (route) => false,
      );
    });
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
      onPressed: _showConfirmationDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B5CF6),
        minimumSize: const Size(double.infinity, 46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        shadowColor: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
      ),
      child: const Text(
        'Confirm Booking',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
