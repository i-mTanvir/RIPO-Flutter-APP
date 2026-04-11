import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/booking_details_screen.dart';

class MyBookingScreen extends StatelessWidget {
  MyBookingScreen({super.key});

  final List<Map<String, dynamic>> _bookings = [
    {
      'id': '215464',
      'price': '\$900',
      'date': '8 Dec 2024-11am 12amm',
      'status': 'Pending',
    },
    {
      'id': '215464',
      'price': '\$900',
      'date': '8 Dec 2024-11am 12amm',
      'status': 'Accepted',
    },
    {
      'id': '215464',
      'price': '\$900',
      'date': '8 Dec 2024-11am 12amm',
      'status': 'In progress',
    },
    {
      'id': '215464',
      'price': '\$900',
      'date': '8 Dec 2024-11am 12amm',
      'status': 'Rejected',
    },
    {
      'id': '215464',
      'price': '\$900',
      'date': '8 Dec 2024-11am 12amm',
      'status': 'Completed',
    },
  ];

  final Map<String, Color> _bgColors = {
    'Pending': const Color(0xFFFDF0D5),
    'Accepted': const Color(0xFFD4C4F7), // Keeping with screenshot's deeper purple tint 
    'In progress': const Color(0xFFE2E4FF),
    'Rejected': const Color(0xFFFADBD8),
    'Completed': const Color(0xFFD5F5E3),
  };

  final Map<String, Color> _textColors = {
    'Pending': const Color(0xFFF39C12),
    'Accepted': const Color(0xFF6950F4),
    'In progress': const Color(0xFF5D5FEF),
    'Rejected': const Color(0xFFE74C3C),
    'Completed': const Color(0xFF27AE60),
  };

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
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE2DCFE), 
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Text(
                  'Filter',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.filter_list_rounded, size: 18, color: Colors.black87),
              ],
            ),
          )
        ],
      ),
      body: ListView.builder(
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
                    Text(
                      'Booking ID:${booking['id']}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _bgColors[status],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textColors[status],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
    );
  }
}
