import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/booking_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = <Map<String, dynamic>>[];

  final Map<String, Color> _bgColors = {
    'Pending': const Color(0xFFFDF0D5),
    'Accepted': const Color(0xFFD4C4F7),
    'In Progress': const Color(0xFFE2E4FF),
    'Rejected': const Color(0xFFFADBD8),
    'Completed': const Color(0xFFD5F5E3),
    'Cancelled': const Color(0xFFF5E6E6),
  };

  final Map<String, Color> _textColors = {
    'Pending': const Color(0xFFF39C12),
    'Accepted': const Color(0xFF6950F4),
    'In Progress': const Color(0xFF5D5FEF),
    'Rejected': const Color(0xFFE74C3C),
    'Completed': const Color(0xFF27AE60),
    'Cancelled': const Color(0xFFB23B3B),
  };

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _bookings = <Map<String, dynamic>>[];
        _isLoading = false;
      });
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final rows = await client
          .from('bookings')
          .select('''
            id,
            booking_code,
            booking_date,
            time_slot_text,
            total_amount,
            booking_status,
            created_at,
            service_id,
            provider_id,
            services(name),
            provider_profiles(owner_name, business_name)
          ''')
          .eq('customer_id', userId)
          .order('created_at', ascending: false);

      final mapped = List<Map<String, dynamic>>.from(rows).map((row) {
        final serviceMap = row['services'] as Map<String, dynamic>?;
        final providerMap = row['provider_profiles'] as Map<String, dynamic>?;
        final serviceName = (serviceMap?['name'] as String?)?.trim() ?? '';
        final ownerName = (providerMap?['owner_name'] as String?)?.trim() ?? '';
        final businessName = (providerMap?['business_name'] as String?)?.trim() ?? '';
        final providerName = ownerName.isNotEmpty ? ownerName : businessName;

        final amount = (row['total_amount'] as num?)?.toDouble() ?? 0;
        final bookingDate = (row['booking_date'] as String?)?.trim() ?? '';
        final timeSlot = (row['time_slot_text'] as String?)?.trim() ?? '';
        final prettyDate = _formatBookingDate(bookingDate, timeSlot);
        final statusLabel = _statusLabel((row['booking_status'] as String?)?.trim() ?? '');

        return <String, dynamic>{
          'id': (row['booking_code'] as String?)?.trim().isNotEmpty == true
              ? (row['booking_code'] as String).trim()
              : (row['id'] as String?) ?? '',
          'bookingId': row['id'],
          'serviceId': row['service_id'],
          'providerId': row['provider_id'],
          'serviceName': serviceName,
          'providerName': providerName,
          'price': 'BDT ${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}',
          'date': prettyDate,
          'status': statusLabel,
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _bookings = mapped;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load bookings.')),
      );
    }
  }

  String _statusLabel(String raw) {
    switch (raw) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  String _formatBookingDate(String bookingDate, String timeSlot) {
    if (bookingDate.isEmpty && timeSlot.isEmpty) return '';
    final dt = DateTime.tryParse(bookingDate);
    if (dt == null) {
      return '$bookingDate ${timeSlot.isEmpty ? '' : '- $timeSlot'}'.trim();
    }

    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final dateText = '${dt.day} ${monthNames[dt.month - 1]} ${dt.year}';
    if (timeSlot.isEmpty) return dateText;
    return '$dateText - $timeSlot';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        title: const Text(
          'My Booking',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _isLoading ? null : _loadBookings,
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE2DCFE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Text(
                    'Refresh',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.refresh_rounded, size: 18, color: Colors.black87),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(
                  child: Text(
                    'No bookings found.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: Colors.black45,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final status = booking['status'] as String;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingDetailsScreen(bookingData: booking),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Booking ID: ${booking['id']}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _bgColors[status] ?? const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _textColors[status] ?? Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                booking['serviceName'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Provider: ${booking['providerName']}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Price: ${booking['price']}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Booking Date: ${booking['date']}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
