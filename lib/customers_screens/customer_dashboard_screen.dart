import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/search_screen.dart';
import 'package:ripo/customers_screens/my_booking_screen.dart';
import 'package:ripo/customers_screens/customer_profile_screen.dart';
import 'package:ripo/customers_screens/location_picker_bottom_sheet.dart';
import 'package:ripo/customers_screens/customer_services_screen.dart';
import 'package:ripo/customers_screens/notification_screen.dart';
import 'package:ripo/customers_screens/service_details_screen.dart';
import 'package:ripo/core/customer_location_service.dart';
import 'package:ripo/core/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _currentOfferPage = 0;
  int _selectedNavIndex = 0;
  String _currentLocationText = 'Detecting location...';
  double? _currentLatitude;
  double? _currentLongitude;
  bool _isResolvingLocation = true;
  bool _hasSavedDefaultLocation = false;

  late final PageController _offerPageController;
  Timer? _offerTimer;

  void _pushScreen(Widget screen) {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen),
      );
    });
  }

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

  List<Map<String, dynamic>> _recommendedServices = [];
  bool _isLoadingRecommended = true;

  final List<Map<String, dynamic>> _allServices = [
    {
      'image': 'lib/media/AC_servicing.png',
      'label': 'AC Repair',
      'bg': const Color(0xFFE8F4FD)
    },
    {
      'image': 'lib/media/electronics_servicing.png',
      'label': 'Electronics',
      'bg': const Color(0xFFFFF3E0)
    },
    {
      'image': 'lib/media/fan_light_servicing.png',
      'label': 'Fan & Light',
      'bg': const Color(0xFFE8F5E9)
    },
    {
      'image': 'lib/media/fridge_servicing.png',
      'label': 'Fridge',
      'bg': const Color(0xFFEDE9FF)
    },
    {
      'image': 'lib/media/paint_servicing.png',
      'label': 'Painting',
      'bg': const Color(0xFFFCE4EC)
    },
    {
      'image': 'lib/media/TV_servicing.png',
      'label': 'TV Repair',
      'bg': const Color(0xFFE3F2FD)
    },
    {
      'image': 'lib/media/water_filter_servicing.png',
      'label': 'Water Filter',
      'bg': const Color(0xFFFFFDE7)
    },
    {
      'icon': Icons.grid_view_rounded,
      'label': 'Explore All',
      'bg': const Color(0xFFF5F5F5)
    },
  ];

  // ── Lifecycle ────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _offerPageController = PageController();
    _startOfferAutoScroll();
    _bootstrapCustomerLocation();
    _loadRecommendedServices();
  }

  Future<void> _bootstrapCustomerLocation() async {
    await _loadSavedDefaultLocation();
    await _resolveCurrentLocationInternal(saveIfMissingOnly: true);
  }

  Future<void> _loadSavedDefaultLocation() async {
    try {
      final saved = await CustomerLocationService.getDefaultLocation();
      if (!mounted || saved == null) return;

      setState(() {
        _currentLocationText = saved.address;
        _currentLatitude = saved.latitude;
        _currentLongitude = saved.longitude;
        _hasSavedDefaultLocation = true;
      });
    } catch (_) {
      // Keep runtime location fallback behavior.
    }
  }

  Future<void> _resolveCurrentLocation() async {
    await _resolveCurrentLocationInternal(saveIfMissingOnly: false);
  }

  Future<void> _resolveCurrentLocationInternal({
    required bool saveIfMissingOnly,
  }) async {
    if (!mounted) return;
    setState(() => _isResolvingLocation = true);

    final result = await LocationService.detectCurrentLocation();
    if (!mounted) return;

    final shouldUpdateUi = !_hasSavedDefaultLocation || !saveIfMissingOnly;
    if (shouldUpdateUi) {
      setState(() {
        _currentLocationText = result.locationText;
        _currentLatitude = result.latitude;
        _currentLongitude = result.longitude;
      });
    }

    if (result.latitude != null &&
        result.longitude != null &&
        (!_hasSavedDefaultLocation || !saveIfMissingOnly)) {
      await _persistCustomerDefaultLocation(
        latitude: result.latitude!,
        longitude: result.longitude!,
        address: result.locationText,
      );
    }

    if (mounted) {
      setState(() => _isResolvingLocation = false);
    }
  }

  Future<void> _openLocationPicker() async {
    final picked = await LocationPickerBottomSheet.show(
      context,
      initialLatitude: _currentLatitude,
      initialLongitude: _currentLongitude,
      initialAddress: _currentLocationText,
    );

    if (!mounted || picked == null) return;
    setState(() {
      _currentLatitude = picked.latitude;
      _currentLongitude = picked.longitude;
      _currentLocationText = picked.address;
    });

    await _persistCustomerDefaultLocation(
      latitude: picked.latitude,
      longitude: picked.longitude,
      address: picked.address,
    );
  }

  Future<void> _persistCustomerDefaultLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      await CustomerLocationService.setDefaultLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      if (!mounted) return;
      setState(() => _hasSavedDefaultLocation = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your default location.')),
      );
    }
  }

  Future<void> _loadRecommendedServices() async {
    final client = Supabase.instance.client;
    try {
      final servicesResponse = await client
          .from('services')
          .select('id, name, regular_price, offer_price, created_at')
          .order('created_at', ascending: false)
          .limit(4)
          .timeout(const Duration(seconds: 12));

      final services = List<Map<String, dynamic>>.from(servicesResponse);
      final serviceIds = services.map((row) => row['id'] as String).toList();

      Map<String, String> coverImageByServiceId = {};
      if (serviceIds.isNotEmpty) {
        final mediaResponse = await client
            .from('service_media')
            .select('service_id, file_url, is_cover, sort_order')
            .inFilter('service_id', serviceIds)
            .order('is_cover', ascending: false)
            .order('sort_order', ascending: true)
            .timeout(const Duration(seconds: 12));

        final mediaRows = List<Map<String, dynamic>>.from(mediaResponse);
        for (final media in mediaRows) {
          final serviceId = media['service_id'] as String?;
          final fileUrl = media['file_url'] as String?;
          if (serviceId == null || fileUrl == null || fileUrl.isEmpty) continue;
          coverImageByServiceId.putIfAbsent(serviceId, () => fileUrl);
        }
      }

      final mapped = services.map((row) {
        final regular = (row['regular_price'] as num?)?.toDouble() ?? 0;
        final offer = (row['offer_price'] as num?)?.toDouble();
        final hasDiscount = offer != null && offer > 0 && offer < regular;
        final discountPct =
            hasDiscount ? (((regular - offer) / regular) * 100).round() : null;
        final serviceId = row['id'] as String?;
        final imageUrl =
            serviceId == null ? '' : (coverImageByServiceId[serviceId] ?? '');

        return <String, dynamic>{
          'id': serviceId ?? '',
          'name': (row['name'] as String?) ?? 'Service',
          'discount': hasDiscount ? '$discountPct% OFF' : 'NEW',
          'price': hasDiscount ? offer.toInt() : regular.toInt(),
          'originalPrice': hasDiscount ? regular.toInt() : null,
          'image': imageUrl,
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _recommendedServices = mapped;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load recommended services.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRecommended = false);
      }
    }
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
          ? const CustomerServicesScreen()
          : _selectedNavIndex == 2
              ? MyBookingScreen()
              : _selectedNavIndex == 3
                  ? CustomerProfileScreen(
                      initialAddress: _currentLocationText,
                      initialLatitude: _currentLatitude,
                      initialLongitude: _currentLongitude,
                      onLocationUpdated: (picked) {
                        if (!mounted) return;
                        setState(() {
                          _currentLocationText = picked.address;
                          _currentLatitude = picked.latitude;
                          _currentLongitude = picked.longitude;
                          _hasSavedDefaultLocation = true;
                        });
                      },
                    )
                  : _buildDashboardBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          onPressed: () => _pushScreen(const SearchScreen()),
          backgroundColor: const Color(0xFF6950F4),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child:
              const Icon(Icons.search_rounded, color: Colors.white, size: 24),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ── Header ───────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB8A8F8), Color(0xFFE8D8FF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
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
                  InkWell(
                    onTap: _openLocationPicker,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 2,
                      ),
                      child: Row(
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
                                children: [
                                  SizedBox(
                                    width: 178,
                                    child: Text(
                                      _currentLocationText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  if (_isResolvingLocation)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 6),
                                      child: SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.8,
                                        ),
                                      ),
                                    )
                                  else
                                    IconButton(
                                      onPressed: _resolveCurrentLocation,
                                      icon: const Icon(
                                        Icons.refresh_rounded,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: 'Current Location',
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _pushScreen(const NotificationScreen());
                    },
                    child: Stack(
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
                  ),
                ],
              ),
            ],
          ),
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
    if (_isLoadingRecommended) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recommendedServices.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: const Text(
          'No services available yet.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _recommendedServices.length,
        itemBuilder: (_, i) =>
            _buildRecomendedServiceCard(_recommendedServices[i]),
      ),
    );
  }

  Widget _buildRecomendedServiceCard(Map<String, dynamic> s) {
    return GestureDetector(
        onTap: () => _pushScreen(ServiceDetailsScreen(serviceData: s)),
        child: Container(
          width: 160,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 8,
                  offset: Offset(0, 4)),
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
                    color: const Color(
                        0xFFF9F9F9), // Light bg for transparent images
                    child: (s['image'] as String).isNotEmpty
                        ? Image.network(
                            s['image'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: Colors.black26),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.image_outlined,
                                color: Colors.black26),
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
                        if (s['originalPrice'] != null)
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
        ));
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
        final isButton =
            s.containsKey('icon'); // Check if it's the 8th item button

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
                _pushScreen(SearchScreen(initialQuery: query));
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
                        fontWeight:
                            isButton ? FontWeight.w700 : FontWeight.w600,
                        color:
                            isButton ? const Color(0xFF6950F4) : Colors.black87,
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
    return BottomAppBar(
      color: Colors.white,
      elevation: 16,
      shadowColor: Colors.black26,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
            _buildNavItem(
                icon: Icons.grid_view_rounded, label: 'Services', index: 1),
            const SizedBox(width: 40), // Reduced space for smaller FAB
            _buildNavItem(
                icon: Icons.calendar_month_outlined,
                label: 'Booking',
                index: 2),
            _buildNavItem(
                icon: Icons.person_outline_rounded, label: 'Profile', index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    final selected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: selected ? const Color(0xFF6950F4) : Colors.black38,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? const Color(0xFF6950F4) : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
