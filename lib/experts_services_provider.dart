import 'package:flutter/material.dart';

class ExpertsServicesProviderScreen extends StatelessWidget {
  const ExpertsServicesProviderScreen({Key? key}) : super(key: key);

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
              child: Opacity(
                opacity: 0.60,
                child: Container(
                  width: 430,
                  height: 126,
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
              left: 31,
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
              left: 74,
              top: 75,
              child: Text(
                'Experts Services Provider',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Search bar
            Positioned(
              left: 26,
              top: 149,
              child: Container(
                width: 379,
                height: 62,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF4F4F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            // Search icon
            Positioned(
              left: 31,
              top: 155,
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/45x45"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Search placeholder text
            Positioned(
              left: 76,
              top: 166,
              child: Opacity(
                opacity: 0.50,
                child: const Text(
                  'Search...',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Filter button
            Positioned(
              left: 306,
              top: 159,
              child: Opacity(
                opacity: 0.50,
                child: Container(
                  width: 92,
                  height: 41,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFAAAFE5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 319,
              top: 171,
              child: Opacity(
                opacity: 0.80,
                child: const Text(
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
            // Provider card 1 - Broom Service
            Positioned(
              left: 31,
              top: 239,
              child: Container(
                width: 374,
                height: 107,
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
            Positioned(
              left: 43,
              top: 254,
              child: Container(
                width: 71,
                height: 78,
                decoration: ShapeDecoration(
                  image: const DecorationImage(
                    image: NetworkImage("https://placehold.co/71x78"),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 130,
              top: 254,
              child: Text(
                'Broom Service',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 130,
              top: 280,
              child: Text(
                'Furniture Cleaning, Microwave  R...',
                style: TextStyle(
                  color: Color(0xFFA09797),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 121,
              top: 299,
              child: Container(
                width: 29,
                height: 25,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/29x25"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 157,
              top: 304,
              child: Text(
                'Mohammapur, Dhaka',
                style: TextStyle(
                  color: Color(0xFF929292),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Provider card 2 - Arlene McCoy
            Positioned(
              left: 31,
              top: 359,
              child: Container(
                width: 374,
                height: 107,
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
            Positioned(
              left: 43,
              top: 371,
              child: Container(
                width: 76.14,
                height: 78,
                decoration: ShapeDecoration(
                  image: const DecorationImage(
                    image: NetworkImage("https://placehold.co/76x78"),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 130,
              top: 375,
              child: Text(
                'Arlene McCoy',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 130,
              top: 402,
              child: Text(
                'Furniture Cleaning, Microwave  R...',
                style: TextStyle(
                  color: Color(0xFFA09797),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 121,
              top: 429,
              child: Container(
                width: 29,
                height: 25,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/29x25"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 157,
              top: 429,
              child: Text(
                'Mohammapur, Dhaka',
                style: TextStyle(
                  color: Color(0xFF929292),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Provider card 3 - Brooklyn Simmons
            Positioned(
              left: 31,
              top: 479,
              child: Container(
                width: 374,
                height: 107,
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
            Positioned(
              left: 43,
              top: 498,
              child: Container(
                width: 75.31,
                height: 78,
                decoration: ShapeDecoration(
                  image: const DecorationImage(
                    image: NetworkImage("https://placehold.co/75x78"),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 130,
              top: 498,
              child: Text(
                'Brooklyn Simmons',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 130,
              top: 525,
              child: Text(
                'Furniture Cleaning, Microwave  R...',
                style: TextStyle(
                  color: Color(0xFFA09797),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 121,
              top: 547,
              child: Container(
                width: 29,
                height: 25,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/29x25"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 157,
              top: 547,
              child: Text(
                'Mohammapur, Dhaka',
                style: TextStyle(
                  color: Color(0xFF929292),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Provider card 4 - Darrell Steward
            Positioned(
              left: 31,
              top: 599,
              child: Container(
                width: 374,
                height: 107,
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
            Positioned(
              left: 43,
              top: 613,
              child: Container(
                width: 71.61,
                height: 78,
                decoration: ShapeDecoration(
                  image: const DecorationImage(
                    image: NetworkImage("https://placehold.co/72x78"),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 130,
              top: 618,
              child: Text(
                'Darrell Steward',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 130,
              top: 645,
              child: Text(
                'Furniture Cleaning, Microwave  R...',
                style: TextStyle(
                  color: Color(0xFFA09797),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 121,
              top: 666,
              child: Container(
                width: 29,
                height: 25,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/29x25"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 157,
              top: 671,
              child: Text(
                'Mohammapur, Dhaka',
                style: TextStyle(
                  color: Color(0xFF929292),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Provider card 5 - Jacob Jones
            Positioned(
              left: 31,
              top: 719,
              child: Container(
                width: 374,
                height: 107,
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
            Positioned(
              left: 43,
              top: 734,
              child: Container(
                width: 69.26,
                height: 78,
                decoration: ShapeDecoration(
                  image: const DecorationImage(
                    image: NetworkImage("https://placehold.co/69x78"),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 130,
              top: 743,
              child: Text(
                'Jacob Jones',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 130,
              top: 765,
              child: Text(
                'Furniture Cleaning, Microwave  R...',
                style: TextStyle(
                  color: Color(0xFFA09797),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: 121,
              top: 787,
              child: Container(
                width: 29,
                height: 25,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/29x25"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 157,
              top: 787,
              child: Text(
                'Mohammapur, Dhaka',
                style: TextStyle(
                  color: Color(0xFF929292),
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