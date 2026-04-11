import 'package:flutter/material.dart';

class ScheduleOrderScreen extends StatelessWidget {
  const ScheduleOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 430,
        height: 932,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned(
              left: 17,
              top: 292,
              child: Container(
                width: 402,
                height: 147,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFAFAFA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: 13,
              top: 461,
              child: Container(
                width: 406,
                height: 309,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFAFAFA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 44,
              top: 355,
              child: Text(
                'Em',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 116,
              top: 147,
              child: Text(
                'Select a Schedule Slot',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 116,
              top: 174,
              child: Text(
                'Please select between our available time\nslots below for delivery of your order',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.50),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Positioned(
              left: 43,
              top: 157,
              child: Container(
                width: 55,
                height: 54,
                decoration: const ShapeDecoration(
                  color: Color(0xFFFFFDFD),
                  shape: OvalBorder(),
                ),
              ),
            ),
            Positioned(
              left: 45,
              top: 159,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/50x50"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 32,
              top: 356,
              child: Text(
                'Today',
                style: TextStyle(
                  color: Color(0xFF6F43D4),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 21,
              top: 466,
              child: Text(
                'At What time should the survice',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 21,
              top: 313,
              child: Text(
                'Select Date',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 73,
              top: 71,
              child: Text(
                'Schedule Order',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 56,
              top: 510,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  '10 AM - 11 AM',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 56,
              top: 577,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  '12 AM - 1 PM',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 72,
              top: 653,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  '2 PM - 3 PM',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 273,
              top: 653,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  '3 PM - 4 PM',
                  style: TextStyle(
                    color: Color(0xFF6F43D4),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 269,
              top: 724,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  '9 PM - 10 PM',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 195,
              top: 840,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: Color(0xFFFCFCFC),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 72,
              top: 724,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  '4 PM - 5 PM',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 266,
              top: 510,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  '11 AM - 12AM',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 268,
              top: 577,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  '1 PM - 12PM',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 88,
              top: 532,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  'Booked',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.50),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 88,
              top: 599,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  'Booked',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.50),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 286,
              top: 532,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  'Booked',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.50),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 289,
              top: 599,
              child: Opacity(
                opacity: 0.90,
                child: Text(
                  'Booked',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.50),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 121,
              top: 355,
              child: Text(
                'Wed',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 199,
              top: 355,
              child: Text(
                'Thu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 283,
              top: 355,
              child: Text(
                'Fri',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 361,
              top: 355,
              child: Text(
                'Sat',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 45,
              top: 388,
              child: Text(
                '12',
                style: TextStyle(
                  color: Color(0xFF6F43D4),
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 127,
              top: 388,
              child: Text(
                '13',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 203,
              top: 388,
              child: Text(
                '14',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 282,
              top: 388,
              child: Text(
                '15',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 363,
              top: 388,
              child: Text(
                '16',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Positioned(
              left: 372,
              top: 305,
              child: Container(
                width: 32,
                height: 31,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/32x31"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}