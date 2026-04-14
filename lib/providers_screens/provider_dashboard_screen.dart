import 'package:flutter/material.dart';
import 'package:ripo/core/location_service.dart';
import 'package:ripo/core/provider_location_service.dart';
import 'package:ripo/customers_screens/notification_screen.dart';
import 'package:ripo/customers_screens/location_picker_bottom_sheet.dart';
import 'package:ripo/providers_screens/provider_jobs_screen.dart';
import 'package:ripo/providers_screens/provider_services_screen.dart';
import 'package:ripo/providers_screens/provider_wallet_screen.dart';
import 'package:ripo/providers_screens/provider_business_profile_screen.dart';
import 'package:ripo/providers_screens/provider_distance_map_bottom_sheet.dart';
import 'package:ripo/providers_screens/provider_schedule_screen.dart';
import 'package:ripo/providers_screens/provider_profile_screen.dart';
import 'package:ripo/providers_screens/add_service_screen.dart';
import 'package:ripo/providers_screens/create_offer_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int _selectedNavIndex = 0;
  bool _showBusinessProfile = false;
  bool _showScheduleScreen = false;
  String _ownerName = 'Provider';
  String _businessName = 'Business';
  String _avatarUrl = '';
  String _currentLocationText = 'Detecting location...';
  double? _currentLatitude;
  double? _currentLongitude;
  bool _isResolvingLocation = true;
  bool _hasSavedDefaultLocation = false;
  bool _isLoadingRecent = true;
  String? _updatingBookingId;
  int _newRequestCount = 0;
  int _completedCount = 0;
  List<Map<String, dynamic>> _recentRequests = <Map<String, dynamic>>[];
  Map<String, String>? _todaySchedule;

  @override
  void initState() {
    super.initState();
    _loadProviderProfile();
    _bootstrapProviderLocation();
    _loadDashboardBookings();
  }

  Future<void> _bootstrapProviderLocation() async {
    await _loadSavedProviderLocation();
    await _resolveCurrentLocationInternal(saveIfMissingOnly: true);
  }

  Future<void> _loadSavedProviderLocation() async {
    try {
      final saved = await ProviderLocationService.getDefaultLocation();
      if (!mounted || saved == null) return;
      setState(() {
        _currentLocationText = saved.address;
        _currentLatitude = saved.latitude;
        _currentLongitude = saved.longitude;
        _hasSavedDefaultLocation = true;
      });
    } catch (_) {
      // Keep runtime fallback.
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
      await _persistProviderLocation(
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

    await _persistProviderLocation(
      latitude: picked.latitude,
      longitude: picked.longitude,
      address: picked.address,
    );
  }

  Future<void> _persistProviderLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      await ProviderLocationService.setDefaultLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      if (!mounted) return;
      setState(() => _hasSavedDefaultLocation = true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save provider location.')),
      );
    }
  }

  Future<void> _showDistanceSheet({
    required String customerAddress,
    required double? customerLat,
    required double? customerLng,
  }) async {
    if (customerLat == null || customerLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer location is not available.')),
      );
      return;
    }

    var providerLat = _currentLatitude;
    var providerLng = _currentLongitude;

    if (providerLat == null || providerLng == null) {
      final saved = await ProviderLocationService.getDefaultLocation();
      providerLat = saved?.latitude;
      providerLng = saved?.longitude;
    }

    if (providerLat == null || providerLng == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set your provider location first.')),
      );
      return;
    }

    if (!mounted) return;
    await ProviderDistanceMapBottomSheet.show(
      context,
      providerLat: providerLat,
      providerLng: providerLng,
      customerLat: customerLat,
      customerLng: customerLng,
      customerAddress: customerAddress,
    );
  }

  Future<void> _loadProviderProfile() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final results = await Future.wait([
        client
            .from('provider_profiles')
            .select('owner_name, business_name')
            .eq('user_id', userId)
            .maybeSingle(),
        client
            .from('profiles')
            .select('avatar_url')
            .eq('id', userId)
            .maybeSingle(),
      ]);

      if (!mounted) return;
      final provider = results[0];
      final profile = results[1];
      final ownerName = (provider?['owner_name'] as String?)?.trim();
      final businessName = (provider?['business_name'] as String?)?.trim();
      final avatarUrl = (profile?['avatar_url'] as String?)?.trim();

      setState(() {
        if (ownerName != null && ownerName.isNotEmpty) {
          _ownerName = ownerName;
        }
        if (businessName != null && businessName.isNotEmpty) {
          _businessName = businessName;
        }
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          _avatarUrl = avatarUrl;
        }
      });
    } catch (_) {
      // Keep default fallback values.
    }
  }

  Future<void> _loadDashboardBookings() async {
    final client = Supabase.instance.client;
    final providerId = client.auth.currentUser?.id;
    if (providerId == null) {
      if (!mounted) return;
      setState(() {
        _isLoadingRecent = false;
        _recentRequests = <Map<String, dynamic>>[];
        _newRequestCount = 0;
        _completedCount = 0;
      });
      return;
    }

    if (mounted) {
      setState(() => _isLoadingRecent = true);
    }

    try {
      final rows = await client
          .from('bookings')
          .select('''
            id,
            booking_date,
            time_slot_text,
            total_amount,
            booking_status,
            customer_id,
            locations(address_line, area, city, latitude, longitude),
            services(name)
          ''')
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      final bookings = List<Map<String, dynamic>>.from(rows);
      final customerIds = bookings
          .map((r) => r['customer_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final customerNameById = <String, String>{};
      final customerAvatarById = <String, String>{};
      if (customerIds.isNotEmpty) {
        final profileRows = await client
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', customerIds);
        for (final row in List<Map<String, dynamic>>.from(profileRows)) {
          final id = row['id'] as String?;
          final name = (row['full_name'] as String?)?.trim() ?? '';
          final avatarUrl = (row['avatar_url'] as String?)?.trim() ?? '';
          if (id != null) {
            customerNameById[id] = name;
            customerAvatarById[id] = avatarUrl;
          }
        }
      }

      final pending = bookings
          .where((e) => (e['booking_status'] as String?) == 'pending')
          .toList();
      final completed = bookings
          .where((e) => (e['booking_status'] as String?) == 'completed')
          .length;

      final recentPending = pending.take(2).map((row) {
        final serviceMap = row['services'] as Map<String, dynamic>?;
        final locationMap = row['locations'] as Map<String, dynamic>?;
        final customerId = row['customer_id'] as String?;
        final amount = (row['total_amount'] as num?)?.toDouble() ?? 0;
        final address = [
          (locationMap?['address_line'] as String?)?.trim() ?? '',
          (locationMap?['area'] as String?)?.trim() ?? '',
          (locationMap?['city'] as String?)?.trim() ?? '',
        ].where((e) => e.isNotEmpty).join(', ');
        final customerLat = (locationMap?['latitude'] as num?)?.toDouble();
        final customerLng = (locationMap?['longitude'] as num?)?.toDouble();

        return <String, dynamic>{
          'id': row['id'] as String? ?? '',
          'name':
              customerId == null ? '' : (customerNameById[customerId] ?? ''),
          'customerAvatarUrl':
              customerId == null ? '' : (customerAvatarById[customerId] ?? ''),
          'service': (serviceMap?['name'] as String?)?.trim() ?? '',
          'address': address,
          'customerLat': customerLat,
          'customerLng': customerLng,
          'date': _formatBookingDate(
            (row['booking_date'] as String?)?.trim() ?? '',
            (row['time_slot_text'] as String?)?.trim() ?? '',
          ),
          'price': amount % 1 == 0
              ? amount.toStringAsFixed(0)
              : amount.toStringAsFixed(2),
        };
      }).toList();

      final todaysSchedule = _extractTodaySchedule(bookings);

      if (!mounted) return;
      setState(() {
        _newRequestCount = pending.length;
        _completedCount = completed;
        _recentRequests = recentPending;
        _todaySchedule = todaysSchedule;
        _isLoadingRecent = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingRecent = false);
    }
  }

  String _formatBookingDate(String bookingDate, String timeSlot) {
    if (bookingDate.isEmpty && timeSlot.isEmpty) return '';
    final dt = DateTime.tryParse(bookingDate);
    if (dt == null) {
      return '$bookingDate ${timeSlot.isEmpty ? '' : '- $timeSlot'}'.trim();
    }
    final months = [
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
    final dateText = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    return timeSlot.isEmpty ? dateText : '$dateText, $timeSlot';
  }

  Map<String, String>? _extractTodaySchedule(
      List<Map<String, dynamic>> bookings) {
    final now = DateTime.now();
    final todayString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final todayRows = bookings.where((row) {
      final bookingDate = (row['booking_date'] as String?)?.trim() ?? '';
      return bookingDate == todayString;
    }).toList();

    if (todayRows.isEmpty) return null;

    List<Map<String, dynamic>> primary = todayRows
        .where((row) => ['accepted', 'in_progress']
            .contains((row['booking_status'] as String?)?.trim() ?? ''))
        .toList();
    if (primary.isEmpty) {
      primary = todayRows
          .where(
              (row) => (row['booking_status'] as String?)?.trim() == 'pending')
          .toList();
    }
    if (primary.isEmpty) return null;

    primary.sort((a, b) {
      final aMin =
          _slotStartMinutes((a['time_slot_text'] as String?)?.trim() ?? '');
      final bMin =
          _slotStartMinutes((b['time_slot_text'] as String?)?.trim() ?? '');
      return aMin.compareTo(bMin);
    });

    final nowMinutes = now.hour * 60 + now.minute;
    Map<String, dynamic> selected = primary.first;
    for (final row in primary) {
      final start =
          _slotStartMinutes((row['time_slot_text'] as String?)?.trim() ?? '');
      if (start >= nowMinutes) {
        selected = row;
        break;
      }
    }

    final serviceMap = selected['services'] as Map<String, dynamic>?;
    final serviceName = (serviceMap?['name'] as String?)?.trim() ?? 'Service';
    final slot = (selected['time_slot_text'] as String?)?.trim() ?? '';

    return {
      'day': now.day.toString().padLeft(2, '0'),
      'month': _monthLabel(now.month),
      'serviceName': serviceName,
      'timeSlot': slot,
    };
  }

  int _slotStartMinutes(String slot) {
    if (slot.isEmpty) return 0;
    final parts = slot.split(RegExp(r'\s*[-–]\s*'));
    if (parts.isEmpty) return 0;
    return _parseSingleTime(parts.first.trim());
  }

  int _parseSingleTime(String raw) {
    final match =
        RegExp(r'^(\d{1,2})(?::(\d{1,2}))?\s*([AaPp][Mm])?$').firstMatch(raw);
    if (match == null) return 0;
    var hour = int.tryParse(match.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
    final ampm = match.group(3)?.toLowerCase();

    if (ampm != null) {
      if (hour == 12) {
        hour = ampm == 'am' ? 0 : 12;
      } else if (ampm == 'pm') {
        hour += 12;
      }
    }
    return hour * 60 + minute;
  }

  String _monthLabel(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  Future<void> _updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    if (_updatingBookingId != null) return;
    final client = Supabase.instance.client;
    final providerId = client.auth.currentUser?.id;
    if (providerId == null) return;

    setState(() => _updatingBookingId = bookingId);
    try {
      await client
          .from('bookings')
          .update({'booking_status': status}).eq('id', bookingId);
      await client.from('booking_status_history').insert({
        'booking_id': bookingId,
        'status': status,
        'changed_by': providerId,
        'note': 'Status updated by provider from dashboard.',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Request ${status == 'accepted' ? 'accepted' : 'declined'}')),
      );
      await _loadDashboardBookings();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update request status.')),
      );
    } finally {
      if (mounted) setState(() => _updatingBookingId = null);
    }
  }

  // â”€â”€ Handlers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showAddActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'What would you like to create?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.add_business_rounded,
                    title: 'New Service',
                    color: const Color(0xFF6950F4),
                    fgColor: const Color(0xFFEDE9FF),
                    onTap: () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      Future.delayed(const Duration(milliseconds: 150), () {
                        navigator.push(
                          MaterialPageRoute(
                              builder: (_) => const AddServiceScreen()),
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.local_offer_rounded,
                    title: 'Create Offer',
                    color: const Color(0xFFFF8F00),
                    fgColor: const Color(0xFFFFF3E0),
                    onTap: () {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      Future.delayed(const Duration(milliseconds: 150), () {
                        navigator.push(
                          MaterialPageRoute(
                              builder: (_) => const CreateOfferScreen()),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Color fgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: fgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: _buildBodyContent(),
      bottomNavigationBar: _showBusinessProfile || _showScheduleScreen
          ? null
          : _buildBottomNav(),
      floatingActionButton: _showBusinessProfile || _showScheduleScreen
          ? null
          : SizedBox(
              width: 48,
              height: 48,
              child: FloatingActionButton(
                onPressed: _showAddActionSheet,
                backgroundColor: const Color(0xFF6950F4),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBodyContent() {
    if (_showBusinessProfile) {
      return ProviderBusinessProfileScreen(
        onBack: () {
          setState(() {
            _showBusinessProfile = false;
          });
        },
      );
    }

    if (_showScheduleScreen) {
      return ProviderScheduleScreen(
        onBack: () {
          setState(() {
            _showScheduleScreen = false;
          });
        },
      );
    }

    // Temporary text block for other tabs for now
    if (_selectedNavIndex == 1) {
      return const ProviderJobsScreen();
    } else if (_selectedNavIndex == 2) {
      return const ProviderServicesScreen();
    } else if (_selectedNavIndex == 3) {
      return const ProviderWalletScreen();
    } else if (_selectedNavIndex == 4) {
      return ProviderProfileScreen(
        ownerName: _ownerName,
        businessName: _businessName,
        avatarUrl: _avatarUrl,
        onBusinessProfileTap: () {
          setState(() {
            _showBusinessProfile = true;
            _showScheduleScreen = false;
          });
        },
        onScheduleTap: () {
          setState(() {
            _showScheduleScreen = true;
            _showBusinessProfile = false;
          });
        },
      );
    }

    // Default Home Screen
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsGrid(),
                const SizedBox(height: 28),
                _buildSectionTitle(
                  'Recent Requests',
                  onTap: () => setState(() => _selectedNavIndex = 1),
                ),
                const SizedBox(height: 16),
                if (_isLoadingRecent)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_recentRequests.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 10,
                            offset: Offset(0, 4)),
                      ],
                    ),
                    child: const Text(
                      'No pending requests.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  ..._recentRequests.asMap().entries.map((entry) {
                    final request = entry.value;
                    final bookingId = request['id'] as String;
                    final isUpdating = _updatingBookingId == bookingId;
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom:
                              entry.key == _recentRequests.length - 1 ? 0 : 12),
                      child: _buildRecentRequestCard(
                        bookingId: bookingId,
                        name: (request['name'] as String).isEmpty
                            ? 'Customer'
                            : request['name'] as String,
                        service: request['service'] as String,
                        address: (request['address'] as String).isEmpty
                            ? 'Address not provided'
                            : request['address'] as String,
                        customerLat: request['customerLat'] as double?,
                        customerLng: request['customerLng'] as double?,
                        date: request['date'] as String,
                        price: request['price'] as String,
                        customerAvatarUrl:
                            request['customerAvatarUrl'] as String,
                        onAddressTap: () => _showDistanceSheet(
                          customerAddress:
                              (request['address'] as String).isEmpty
                                  ? 'Address not provided'
                                  : request['address'] as String,
                          customerLat: request['customerLat'] as double?,
                          customerLng: request['customerLng'] as double?,
                        ),
                        onDecline: isUpdating
                            ? null
                            : () => _updateBookingStatus(
                                bookingId: bookingId, status: 'rejected'),
                        onAccept: isUpdating
                            ? null
                            : () => _updateBookingStatus(
                                bookingId: bookingId, status: 'accepted'),
                      ),
                    );
                  }),
                const SizedBox(height: 28),
                _buildSectionTitle('Today\'s Schedule'),
                const SizedBox(height: 16),
                _buildScheduleCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildHeader() {
    final ImageProvider avatarProvider = _avatarUrl.isNotEmpty
        ? NetworkImage(_avatarUrl)
        : const AssetImage('lib/media/clean_house_offer.png');

    return Container(
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      image: DecorationImage(
                        image: avatarProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _ownerName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      InkWell(
                        onTap: _openLocationPicker,
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 170,
                              child: Text(
                                _currentLocationText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
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
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  _buildHeaderIconButton(
                    icon: Icons.notifications_outlined,
                    hasBadge: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationScreen()),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton(
      {required IconData icon,
      required VoidCallback onTap,
      bool hasBadge = false}) {
    return GestureDetector(
      onTap: onTap,
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
            child: Icon(icon, color: Colors.black87, size: 22),
          ),
          if (hasBadge)
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
    );
  }

  // â”€â”€ Stats Grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Today\'s Earnings',
            value: '৳ 3,200',
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF6950F4),
            bgColor: const Color(0xFFEDE9FF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildSmallStat(
                title: 'New Requests',
                value: '$_newRequestCount',
                icon: Icons.person_add_rounded,
                color: const Color(0xFFFF8F00),
                bgColor: const Color(0xFFFFF3E0),
              ),
              const SizedBox(height: 12),
              _buildSmallStat(
                title: 'Completed',
                value: '$_completedCount',
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF43A047),
                bgColor: const Color(0xFFE8F5E9),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSmallStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // â”€â”€ Section Title â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildSectionTitle(String title, {VoidCallback? onTap}) {
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
          onTap: onTap,
          child: Text(
            'See All',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: onTap == null ? Colors.black38 : const Color(0xFF6950F4),
            ),
          ),
        ),
      ],
    );
  }

  // â”€â”€ Recent Request Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildRecentRequestCard({
    required String bookingId,
    required String name,
    required String service,
    required String address,
    required double? customerLat,
    required double? customerLng,
    required String date,
    required String price,
    required String customerAvatarUrl,
    required VoidCallback onAddressTap,
    required VoidCallback? onDecline,
    required VoidCallback? onAccept,
  }) {
    final ImageProvider? avatarProvider =
        customerAvatarUrl.isEmpty ? null : NetworkImage(customerAvatarUrl);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    color: Color(0xFFE8F4FD), shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: avatarProvider == null
                    ? const Icon(Icons.person,
                        color: Color(0xFF1E88E5), size: 24)
                    : Image(
                        image: avatarProvider,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(service,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Color(0xFF6950F4),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Text('BDT $price',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 14, color: Colors.black38),
              const SizedBox(width: 6),
              Expanded(
                child: InkWell(
                  onTap: (customerLat != null &&
                          customerLng != null &&
                          address != 'Address not provided')
                      ? onAddressTap
                      : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 14, color: Colors.black38),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF5252)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Decline',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFF5252))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6950F4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Accept',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // â”€â”€ Schedule Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildScheduleCard() {
    final schedule = _todaySchedule;
    if (schedule == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.event_busy_outlined, color: Colors.black45),
            SizedBox(width: 10),
            Text(
              'No schedule for today.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6950F4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x336950F4), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(schedule['day'] ?? '--',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                Text(schedule['month'] ?? '---',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(schedule['serviceName'] ?? 'Service',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(schedule['timeSlot'] ?? '',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  // â”€â”€ Bottom Nav â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 16,
      shadowColor: Colors.black26,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
            _buildNavItem(
                icon: Icons.work_outline_rounded, label: 'Jobs', index: 1),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(
                icon: Icons.grid_view_rounded, label: 'Services', index: 2),
            _buildNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                index: 4), // Index 4 due to gap
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    final selected = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
          _showBusinessProfile = false; // Reset sub-views when changing tabs
          _showScheduleScreen = false;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
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
