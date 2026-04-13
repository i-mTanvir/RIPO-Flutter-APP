import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/booking_schedule.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? serviceData;
  final bool isProviderPreview;

  const ServiceDetailsScreen({
    super.key, 
    this.serviceData, 
    this.isProviderPreview = false,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = [
    'Overview',
    'Service Variation',
    'Review',
    'FAQs'
  ];

  @override
  Widget build(BuildContext context) {
    String baseImage = widget.serviceData?['image'] ?? 'lib/media/AC_servicing.png';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSlider(baseImage),
            _buildServiceBasicInfo(),
            _buildTabSelector(),
            const SizedBox(height: 16),
            if (_selectedTabIndex == 0) _buildOverviewSection(),
            if (_selectedTabIndex == 1) _buildVariationSection(),
            if (_selectedTabIndex == 2) _buildReviewSection(),
            if (_selectedTabIndex == 3) _buildFAQSection(),
            const SizedBox(height: 100), // padding for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.isProviderPreview ? 'Service Preview' : 'Service Details',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        if (!widget.isProviderPreview) ...[
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            width: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5FF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite_border_rounded,
                  color: Color(0xFF6950F4), size: 20),
              onPressed: () {},
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            width: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5E5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.reply_rounded,
                  color: Color(0xFFFF9800), size: 20),
              onPressed: () {},
            ),
          ),
        ] else ...[
          Container(
             alignment: Alignment.center,
             padding: const EdgeInsets.only(right: 16),
             child: const Text('PREVIEW', style: TextStyle(fontFamily: 'Inter', color: Color(0xFF6950F4), fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ]
      ],
    );
  }

  Widget _buildImageSlider(String imageUrl) {
    return Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF5F5F5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildServiceBasicInfo() {
    final name = widget.serviceData?['name'] ?? 'AC Cooling Problem';
    final price = widget.serviceData?['price']?.toString() ?? '500';
    final orgPrice = widget.serviceData?['originalPrice']?.toString() ?? '600';
    final discount = widget.serviceData?['discount'] ?? '30% OFF';
    final rating = widget.serviceData?['rating']?.toString() ?? '4.5';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'AC Repair', // Mock category
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '৳ $price',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6950F4), // Purple price
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '৳ $orgPrice',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black38,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  discount,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Duration: 30 min',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    ' (10 Reviews)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.location_on_outlined, color: Colors.black54, size: 18),
              SizedBox(width: 4),
              Text(
                'Distance: 2.5 km away',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEDE9FF) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFFEDE9FF) : Colors.black12,
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF6950F4) : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                height: 1.5,
                color: Colors.black54,
              ),
              children: [
                TextSpan(
                    text:
                        'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s... '),
                TextSpan(
                  text: 'Read More v',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6950F4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Service Provider',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x0A000000)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F4FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Color(0xFF6950F4)), // Avatar placeholder
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shaidul Islam',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '4.5 (10 Reviews)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF6950F4)),
                  onPressed: () {},
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Extra Service',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select the one which you need.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Available Variations',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '• Standard AC Maintenance\n• Deep Chemical Cleaning\n• Filter Replacement Package',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.black54,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '1. How long does the service take?\nTypically 30-45 minutes depending on the scale.\n\n2. Are parts/components included in the price?\nNo, additional parts are charged separately.',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.black54,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Reviews',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildReviewCard('Tanvir', '2 days ago', '5.0',
              'Great service! The technician was extremely polite and solved the core issue perfectly on-time.'),
          const Divider(),
          _buildReviewCard('John Doe', '1 week ago', '4.0',
              'Service was reliable and they cleaned up nicely afterward. Would definitely use this platform again.'),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
      String name, String time, String rating, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEDE9FF),
                child: Text(
                  name[0],
                  style: const TextStyle(
                      color: Color(0xFF6950F4), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: widget.isProviderPreview 
            ? () { Navigator.pop(context); } 
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingScheduleScreen(serviceData: widget.serviceData),
                  ),
                );
              },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isProviderPreview ? Colors.white : const Color(0xFF6950F4),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: widget.isProviderPreview ? const BorderSide(color: Color(0xFF6950F4), width: 2) : BorderSide.none,
            ),
            elevation: 0,
          ),
          child: Text(
            widget.isProviderPreview ? 'Close Preview' : 'Book / Schedule Service',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isProviderPreview ? const Color(0xFF6950F4) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
