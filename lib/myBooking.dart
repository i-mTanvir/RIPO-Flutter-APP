import 'package:flutter/material.dart';

class MyBookingScreen extends StatelessWidget {
  const MyBookingScreen({Key? key}) : super(key: key);

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
              left: 0,
              top: 0,
              child: Container(
                width: 430,
                height: 132,
                decoration: const BoxDecoration(
                  color: Colors.white,
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
            // Filter button
            Positioned(
              left: 311,
              top: 82,
              child: Opacity(
                opacity: 0.50,
                child: Container(
                  width: 92,
                  height: 31,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFAAAFE5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 330,
              top: 89,
              child: Opacity(
                opacity: 0.80,
                child: Text(
                  'Filter',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 34,
              top: 85,
              child: Text(
                'My Booking',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Booking card 1 (Pending)
            Positioned(
              left: 34,
              top: 178,
              child: Container(
                width: 375,
                height: 110,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFAFAFA),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 2,
                      color: Colors.black.withOpacity(0.10),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 69,
              top: 207,
              child: Text(
                'Booking ID:215464',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 298,
              top: 200,
              child: Container(
                width: 102,
                height: 36,
                decoration: ShapeDecoration(
                  color: const Color(0x60F6DA99),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 318,
              top: 209,
              child: Text(
                'Pending',
                style: TextStyle(
                  color: Color(0xFFF8830E),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 63,
              top: 236,
              child: Text(
                'Price: \$900\nBooking Date: 8 Dec 2024-11am 12amm',
                style: TextStyle(
                  color: Color(0xFFB0ABAB),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Booking card 2 (Accepted)
            Positioned(
              left: 37,
              top: 325,
              child: Container(
                width: 375,
                height: 110,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFAFAFA),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 2,
                      color: Colors.black.withOpacity(0.10),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 69,
              top: 340,
              child: Text(
                'Booking ID:215464',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 298,
              top: 334,
              child: Container(
                width: 102,
                height: 36,
                decoration: ShapeDecoration(
                  color: const Color(0x607E64D6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 316,
              top: 343,
              child: Text(
                'Accepted',
                style: TextStyle(
                  color: Color(0xFF795FEB),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 63,
              top: 374,
              child: Text(
                'Price: \$900\nBooking Date: 8 Dec 2024-11am 12amm',
                style: TextStyle(
                  color: Color(0xFFB0ABAB),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Booking card 3 (In progress)
            Positioned(
              left: 34,
              top: 472,
              child: Container(
                width: 375,
                height: 110,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFAFAFA),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 2,
                      color: Colors.black.withOpacity(0.10),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 69,
              top: 487,
              child: Text(
                'Booking ID:215464',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 298,
              top: 483,
              child: Container(
                width: 102,
                height: 36,
                decoration: ShapeDecoration(
                  color: const Color(0x60B9B7F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 311,
              top: 491,
              child: Text(
                'In progress',
                style: TextStyle(
                  color: Color(0xFF5C53E5),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 63,
              top: 527,
              child: Text(
                'Price: \$900\nBooking Date: 8 Dec 2024-11am 12amm',
                style: TextStyle(
                  color: Color(0xFFB0ABAB),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Booking card 4 (Rejected)
            Positioned(
              left: 34,
              top: 629,
              child: Container(
                width: 375,
                height: 110,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFAFAFA),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 2,
                      color: Colors.black.withOpacity(0.10),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 69,
              top: 651,
              child: Text(
                'Booking ID:215464',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 298,
              top: 642,
              child: Container(
                width: 102,
                height: 36,
                decoration: ShapeDecoration(
                  color: const Color(0x60F69999),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 316,
              top: 650,
              child: Text(
                'Rejected',
                style: TextStyle(
                  color: Color(0xFFFA1111),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 63,
              top: 687,
              child: Text(
                'Price: \$900\nBooking Date: 8 Dec 2024-11am 12amm',
                style: TextStyle(
                  color: Color(0xFFB0ABAB),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Booking card 5 (Completed)
            Positioned(
              left: 34,
              top: 776,
              child: Container(
                width: 375,
                height: 110,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFAFAFA),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 2,
                      color: Colors.black.withOpacity(0.10),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 69,
              top: 792,
              child: Text(
                'Booking ID:215464',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 298,
              top: 783,
              child: Container(
                width: 102,
                height: 36,
                decoration: ShapeDecoration(
                  color: const Color(0x609DF699),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 308,
              top: 792,
              child: Text(
                'Completed',
                style: TextStyle(
                  color: Color(0xFF2C940C),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Bottom navigation bar
            Positioned(
              left: 0,
              top: 838,
              child: Container(
                width: 430,
                height: 92,
                decoration: const BoxDecoration(
                  color: Colors.white,
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
            // Cart notification badge
            Positioned(
              left: 213,
              top: 857,
              child: Container(
                width: 16,
                height: 12,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF9891A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 217,
              top: 857,
              child: SizedBox(
                width: 7,
                child: Text(
                  '2',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFFDFD),
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Navigation icons
            Positioned(
              left: 23,
              top: 857,
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/35x35"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 99,
              top: 857,
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/35x35"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 191,
              top: 863,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/30x30"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 270,
              top: 857,
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/35x35"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 348,
              top: 857,
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/35x35"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Navigation labels
            const Positioned(
              left: 23,
              top: 895,
              child: SizedBox(
                width: 35,
                child: Text(
                  'Home',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 89,
              top: 895,
              child: SizedBox(
                width: 55,
                child: Text(
                  'Category',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.60),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 193,
              top: 895,
              child: SizedBox(
                width: 26,
                child: Text(
                  'Cart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.60),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 265,
              top: 895,
              child: SizedBox(
                width: 48,
                child: Text(
                  'Booking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF5D53E6),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 348,
              top: 895,
              child: SizedBox(
                width: 38,
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.60),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
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