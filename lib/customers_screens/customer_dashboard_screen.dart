import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/search_screen.dart';
import 'package:ripo/customers_screens/my_booking_screen.dart';
import 'package:ripo/customers_screens/customer_profile_screen.dart';
import 'package:ripo/customers_screens/category_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _currentOfferPage = 0;
  int _selectedNavIndex = 0;
  int _selectedServiceIndex = 0;

  late final PageController _offerPageController;
  Timer? _offerTimer;

  // ── Data ────────────────────────────────────────────────────

  final List<Map<String, dynamic>> _offers = [
    {
      'title': 'House\nCleaning',
      'discount': '50',
      'image': 'lib/media/clean_house_offer.png',
      'bg': const Color(0xFFEDE9FF)
    },
    {
      'title': 'Laundry\nWashing',
      'discount': '30',
      'image': 'lib/media/loundry_washing_offer.png',
      'bg': const Color(0xFFE8F4FD)
    },
  ];

  final List<Map<String, dynamic>> _commonServices = [
    {'icon': Icons.ac_unit_rounded,           'label': 'AC Repair'},
    {'icon': Icons.handyman_rounded,          'label': 'Carpenter'},
    {'icon': Icons.local_shipping_rounded,    'label': 'Shifting'},
    {'icon': Icons.cleaning_services_rounded, 'label': 'Cleaning'},
    {'icon': Icons.restaurant_rounded,        'label': 'Cooking'},
    {'icon': Icons.plumbing_rounded,          'label': 'Plumbing'},
    {'icon': Icons.electrical_services,       'label': 'Electric'},
  ];

  final List<Map<String, dynamic>> _recommendedServices = [
    {
      'name': 'AC Servicing',
      'discount': '40% OFF',
      'price': '1,200',
      'originalPrice': '2,000',
      'image': 'lib/media/AC_servicing.png',
    },
    {
      'name': 'Electronics Service',
      'discount': '50% OFF',
      'price': '800',
      'originalPrice': '1,600',
      'image': 'lib/media/electronics_servicing.png',
    },
    {
      'name': 'Fan & Light Service',
      'discount': '30% OFF',
      'price': '500',
      'originalPrice': '700',
      'image': 'lib/media/fan_light_servicing.png',
    },
  ];

  final List<Map<String, dynamic>> _allServices = [
    {'image': 'lib/media/AC_servicing.png',           'label': 'AC Repair',    'bg': const Color(0xFFE8F4FD)},
    {'image': 'lib/media/electronics_servicing.png',  'label': 'Electronics',  'bg': const Color(0xFFFFF3E0)},
    {'image': 'lib/media/fan_light_servicing.png',    'label': 'Fan & Light',  'bg': const Color(0xFFE8F5E9)},
    {'image': 'lib/media/fridge_servicing.png',       'label': 'Fridge',       'bg': const Color(0xFFEDE9FF)},
    {'image': 'lib/media/paint_servicing.png',        'label': 'Painting',     'bg': const Color(0xFFFCE4EC)},
    {'image': 'lib/media/TV_servicing.png',           'label': 'TV Repair',    'bg': const Color(0xFFE3F2FD)},
    {'image': 'lib/media/water_filter_servicing.png', 'label': 'Water Filter', 'bg': const Color(0xFFFFFDE7)},
    {'icon': Icons.grid_view_rounded,                 'label': 'Explore All',  'bg': const Color(0xFFF5F5F5)},
  ];

  // ── Lifecycle ────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _offerPageController = PageController();
    _startOfferAutoScroll();
  }

  void _startOfferAutoScroll() {
    _offerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_offerPageController.hasClients) {
        final next = (_currentOfferPage + 1) % _offers.length;
        _offerPageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _offerTimer?.cancel();
    _offerPageController.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────

  Widget _buildDashboardBody() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCommonServices(),
                const SizedBox(height: 22),
                _buildOfferBanner(),
                const SizedBox(height: 24),
                _buildSectionHeader('Recommended Services'),
                const SizedBox(height: 14),
                _buildRecommendedServices(),
                const SizedBox(height: 26),
                _buildSectionHeader('All Services'),
                const SizedBox(height: 14),
                _buildAllServicesGrid(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: _selectedNavIndex == 1
          ? CategoryScreen()
          : _selectedNavIndex == 2
              ? MyBookingScreen()
              : _selectedNavIndex == 3
                  ? CustomerProfileScreen()
                  : _buildDashboardBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Header ───────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB8A8F8), Color(0xFFE8D8FF)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
          child: Column(
            children: [
              // ── Location + Bell ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF6950F4),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Service In',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: const [
                              Text(
                                'Tongi, Gazipur',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.arrow_drop_down_rounded,
                                  size: 18, color: Colors.black54),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.black87,
                          size: 22,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Search bar ──
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Search ...',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.black38,
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Common Services ──────────────────────────────────────────

  Widget _buildCommonServices() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_commonServices.length, (i) {
            final s = _commonServices[i];
            final selected = _selectedServiceIndex == i;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedServiceIndex = i);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(initialQuery: s['label'] as String),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 22),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFEDE9FF)
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        s['icon'] as IconData,
                        size: 26,
                        color: selected
                            ? const Color(0xFF6950F4)
                            : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s['label'] as String,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? const Color(0xFF6950F4)
                            : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: selected ? 20 : 0,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6950F4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Offer Banner ─────────────────────────────────────────────

  Widget _buildOfferBanner() {
    return Column(
      children: [
        SizedBox(
          height: 145,
          child: PageView.builder(
            controller: _offerPageController,
            itemCount: _offers.length,
            onPageChanged: (i) => setState(() => _currentOfferPage = i),
            itemBuilder: (_, i) => _buildOfferCard(_offers[i]),
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _offers.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentOfferPage == i ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentOfferPage == i
                    ? const Color(0xFF6950F4)
                    : const Color(0x33000000),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: offer['bg'] as Color,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Text section (60%)
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 0, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    offer['title'] as String,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${offer['discount']}%',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6950F4),
                          ),
                        ),
                        const TextSpan(
                          text: ' OFF',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Image section (40%)
          Expanded(
            flex: 4,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                offer['image'] as String,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'See All',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
            ),
          ),
        ),
      ],
    );
  }

  // ── Recommended Services ─────────────────────────────────────

  Widget _buildRecommendedServices() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _recommendedServices.length,
        itemBuilder: (_, i) => _buildRecomendedServiceCard(_recommendedServices[i]),
      ),
    );
  }

  Widget _buildRecomendedServiceCard(Map<String, dynamic> s) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), 
            blurRadius: 8, 
            offset: Offset(0, 4)
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + discount badge
          Stack(
            children: [
              Container(
                height: 110,
                width: 160,
                color: const Color(0xFFF9F9F9), // Light bg for transparent images
                child: Image.asset(
                  s['image'] as String,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s['discount'] as String,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Details
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s['name'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '৳ ${s['price']}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '৳ ${s['originalPrice']}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.black38,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── All Services Grid ─────────────────────────────────────────

  Widget _buildAllServicesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      clipBehavior: Clip.none,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns exactly as requested
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5, // Perfect ratio for horizontal card
      ),
      itemCount: _allServices.length,
      itemBuilder: (_, i) {
        final s = _allServices[i];
        final isButton = s.containsKey('icon'); // Check if it's the 8th item button

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final query = isButton ? '' : s['label'] as String;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(initialQuery: query),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: s['bg'] as Color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isButton
                        ? Icon(
                            s['icon'] as IconData,
                            color: const Color(0xFF6950F4),
                            size: 22,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              s['image'] as String,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s['label'] as String,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: isButton ? FontWeight.w700 : FontWeight.w600,
                        color: isButton ? const Color(0xFF6950F4) : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isButton)
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFF6950F4),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Bottom Nav Bar ────────────────────────────────────────────

  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded,              'label': 'Home'},
      {'icon': Icons.grid_view_rounded,         'label': 'Category'},
      {'icon': Icons.calendar_month_outlined,   'label': 'Booking'},
      {'icon': Icons.person_outline_rounded,    'label': 'Profile'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _selectedNavIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = i),
                child: Container(
                  color: Colors.transparent, // expand tap area
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        size: 26,
                        color: selected
                            ? const Color(0xFF6950F4)
                            : Colors.black38,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected
                              ? const Color(0xFF6950F4)
                              : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
