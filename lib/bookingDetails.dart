import 'package:flutter/material.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({Key? key}) : super(key: key);

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
            // Top header
            Positioned(
              left: -1,
              top: 1,
              child: Opacity(
                opacity: 0.60,
                child: Container(
                  width: 430,
                  height: 115,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFAFA),
                    boxShadow: [
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
            ),
            // Back button
            Positioned(
              left: 25,
              top: 75,
              child: Container(
                width: 23,
                height: 22,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/23x22"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Title
            const Positioned(
              left: 66,
              top: 77,
              child: Text(
                'Booking Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Pending status badge
            Positioned(
              left: 241,
              top: 71,
              child: Container(
                width: 80,
                height: 29,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFAE8D7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 259,
              top: 78,
              child: Text(
                'pending',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFF9737),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // More options button
            Positioned(
              left: 342,
              top: 70,
              child: Container(
                width: 30,
                height: 27,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
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
              left: 350,
              top: 76,
              child: Container(
                width: 15,
                height: 14,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/15x14"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Booking info card
            Positioned(
              left: 23,
              top: 144,
              child: Opacity(
                opacity: 0.55,
                child: Container(
                  width: 383,
                  height: 215,
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
            ),
            // Booking ID
            const Positioned(
              left: 38,
              top: 155,
              child: Text(
                'Booking Id:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 115,
              top: 155,
              child: Text(
                '245148',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF684FF3),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Timestamp
            const Positioned(
              left: 38,
              top: 178,
              child: Text(
                '12 May 2024-10:30AM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF908B8B),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Service image/map
            Positioned(
              left: 39,
              top: 208,
              child: Container(
                width: 328,
                height: 65,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/328x65"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // View button
            Positioned(
              left: 325,
              top: 160,
              child: Opacity(
                opacity: 0.90,
                child: Container(
                  width: 42,
                  height: 33,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF6950F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
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
            ),
            const Positioned(
              left: 331,
              top: 160,
              child: Text(
                '>\nView',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Booking Summary section
            const Positioned(
              left: 39,
              top: 279,
              child: Text(
                'Booking Summary',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 40,
              top: 309,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Booking Date:',
                      style: TextStyle(
                        color: Color(0xFFB6B0B0),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: ' 8 Dec 2024-11am-12pm\n',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Positioned(
              left: 41,
              top: 331,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Address:',
                      style: TextStyle(
                        color: Color(0xFFAEAAAA),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: ' house 57,Road 25, Block A, Banani',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Service Provider card
            Positioned(
              left: 27,
              top: 398,
              child: Container(
                width: 379,
                height: 106,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFCFCFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 9,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 36,
              top: 406,
              child: Text(
                'Service Provider',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 295,
              top: 414,
              child: Text(
                'Write Review',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFC5C1C1),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Provider profile image
            Positioned(
              left: 36,
              top: 425,
              child: Container(
                width: 72,
                height: 68,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/72x68"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Online status indicator
            Positioned(
              left: 88,
              top: 429,
              child: Container(
                width: 10,
                height: 10,
                decoration: ShapeDecoration(
                  color: const Color(0xFF148A1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            // Provider name
            const Positioned(
              left: 110,
              top: 438,
              child: Text(
                'Tanvir Mahmud',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Call button
            Positioned(
              left: 121,
              top: 467,
              child: Container(
                width: 86,
                height: 26,
                decoration: ShapeDecoration(
                  color: const Color(0xFF5940E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 130,
              top: 470,
              child: Container(
                width: 21,
                height: 23,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/21x23"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 157,
              top: 472,
              child: Text(
                'Call',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Chat button
            Positioned(
              left: 223,
              top: 467,
              child: Container(
                width: 98,
                height: 26,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF3EEEE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
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
              left: 244,
              top: 474,
              child: Container(
                width: 19,
                height: 14,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/19x14"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 269,
              top: 473,
              child: Text(
                'Chat',
                style: TextStyle(
                  color: Color(0xFF5940E5),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Payment Method card
            Positioned(
              left: 25,
              top: 543,
              child: Container(
                width: 383,
                height: 143,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFCFCFC),
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
              left: 48,
              top: 562,
              child: Text(
                'Payment Method',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Unpaid badge
            Positioned(
              left: 292,
              top: 562,
              child: Opacity(
                opacity: 0.50,
                child: Container(
                  width: 92,
                  height: 37,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF3A9A9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 314,
              top: 571,
              child: Text(
                'Unpaid',
                style: TextStyle(
                  color: Color(0xFFF23838),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Payment details
            const Positioned(
              left: 48,
              top: 599,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Payment by: Pay Offline\n\nTotal Amount:',
                      style: TextStyle(
                        color: Color(0xFFB1A7A7),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' ',
                      style: TextStyle(
                        color: Color(0xFF191515),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' \$900',
                      style: TextStyle(
                        color: Color(0xFF191515),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Service Summary card
            Positioned(
              left: 25,
              top: 723,
              child: Container(
                width: 383,
                height: 133,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFCFCFC),
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
              left: 42,
              top: 745,
              child: Text(
                'Service  Summary',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Positioned(
              left: 43,
              top: 792,
              child: Text(
                'AC Cooling Problem',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 43,
              top: 821,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Qty:',
                      style: TextStyle(
                        color: Color(0xFFCAC8C8),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '1',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 342,
              top: 829,
              child: Text(
                '\$500',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}