import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/notification_screen.dart';
import 'package:ripo/providers_screens/provider_jobs_screen.dart';
import 'package:ripo/providers_screens/provider_services_screen.dart';
import 'package:ripo/providers_screens/provider_wallet_screen.dart';
import 'package:ripo/providers_screens/provider_business_profile_screen.dart';
import 'package:ripo/providers_screens/provider_schedule_screen.dart';
import 'package:ripo/providers_screens/provider_profile_screen.dart';
import 'package:ripo/providers_screens/add_service_screen.dart';
import 'package:ripo/providers_screens/create_offer_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int _selectedNavIndex = 0;
  bool _showBusinessProfile = false;
  bool _showScheduleScreen = false;
  String _ownerName = 'Provider';
  String _businessName = 'Business';
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProviderProfile();
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
        client.from('profiles').select('avatar_url').eq('id', userId).maybeSingle(),
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

  // ── Handlers ─────────────────────────────────────────────────────────────

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
                          MaterialPageRoute(builder: (_) => const AddServiceScreen()),
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
                          MaterialPageRoute(builder: (_) => const CreateOfferScreen()),
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

  // ── Build ────────────────────────────────────────────────────────────────

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
                _buildSectionTitle('Recent Requests'),
                const SizedBox(height: 16),
                _buildRecentRequestCard(
                  name: 'Rahim Ahmed',
                  service: 'AC Servicing',
                  address: 'Sector 4, Uttara, Dhaka',
                  date: 'Today, 2:30 PM',
                  price: '1,200',
                  avatar: Icons.person,
                ),
                const SizedBox(height: 12),
                _buildRecentRequestCard(
                  name: 'Tania Islam',
                  service: 'House Cleaning',
                  address: 'Tongi, Gazipur',
                  date: 'Tomorrow, 10:00 AM',
                  price: '800',
                  avatar: Icons.person_3,
                ),
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

  // ── Header ───────────────────────────────────────────────────────────────

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
                      const Text(
                        'Good Morning,',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _ownerName,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
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
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
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

  Widget _buildHeaderIconButton({required IconData icon, required VoidCallback onTap, bool hasBadge = false}) {
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

  // ── Stats Grid ───────────────────────────────────────────────────────────

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
                value: '4',
                icon: Icons.person_add_rounded,
                color: const Color(0xFFFF8F00),
                bgColor: const Color(0xFFFFF3E0),
              ),
              const SizedBox(height: 12),
              _buildSmallStat(
                title: 'Completed',
                value: '12',
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
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
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
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
                 Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500)),
               ],
            ),
          )
        ],
      ),
    );
  }

  // ── Section Title ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
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
        const Text(
          'See All',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6950F4),
          ),
        ),
      ],
    );
  }

  // ── Recent Request Card ──────────────────────────────────────────────────

  Widget _buildRecentRequestCard({
    required String name,
    required String service,
    required String address,
    required String date,
    required String price,
    required IconData avatar,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
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
                decoration: const BoxDecoration(color: Color(0xFFE8F4FD), shape: BoxShape.circle),
                child: Icon(avatar, color: const Color(0xFF1E88E5), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(service, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF6950F4), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Text('৳ $price', style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: Colors.black38),
              const SizedBox(width: 6),
              Text(address, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: Colors.black38),
              const SizedBox(width: 6),
              Text(date, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF5252)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Decline', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFFF5252))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6950F4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Accept', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ── Schedule Card ────────────────────────────────────────────────────────

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6950F4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x336950F4), blurRadius: 12, offset: Offset(0, 6)),
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
            child: const Column(
              children: [
                 Text('14', style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                 Text('APR', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TV Repairing Service', style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.white70),
                    SizedBox(width: 6),
                    Text('11:00 AM - 12:30 PM', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────

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
            _buildNavItem(icon: Icons.work_outline_rounded, label: 'Jobs', index: 1),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(icon: Icons.grid_view_rounded, label: 'Services', index: 2),
            _buildNavItem(icon: Icons.person_outline_rounded, label: 'Profile', index: 4), // Index 4 due to gap
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
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
