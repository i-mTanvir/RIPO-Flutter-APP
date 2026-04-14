import 'package:flutter/material.dart';
import 'package:ripo/admin_screens/admin_users_screen.dart';
import 'package:ripo/admin_screens/admin_offers_screen.dart';
import 'package:ripo/admin_screens/settings_screen.dart';
import 'package:ripo/admin_screens/admin_finance_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedNavIndex = 0;

  Widget _buildBodyContent() {
    // Scaffold Body Hub
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _selectedNavIndex == 1 || _selectedNavIndex == 3
              // Component screens (Users, Offers) have their own padding logic.
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  child: _buildActiveTabContent())
              : _selectedNavIndex == 4
                  // Settings/Profile screen manages its own Column + Expanded structure.
                  ? _buildActiveTabContent()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: _buildActiveTabContent(),
                    ),
        ),
      ],
    );
  }

  Widget _buildActiveTabContent() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildOverviewContent();
      case 1:
        return const AdminUsersScreen();
      case 2:
        return const AdminFinanceScreen();
      case 3:
        return const AdminOffersScreen();
      case 4:
        return const AdminSettingsScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    'Total Revenue',
                    '৳ 145K',
                    Icons.account_balance_wallet_rounded,
                    const Color(0xFF6950F4))),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatCard('Active Jobs', '342',
                    Icons.handyman_rounded, const Color(0xFF00BFA5))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildStatCard('Total Users', '12.4K',
                    Icons.people_alt_rounded, const Color(0xFFFF9800))),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatCard('Providers', '850',
                    Icons.storefront_rounded, const Color(0xFFE91E63))),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Recent Activities',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.black87)),
        const SizedBox(height: 10),
        _buildActivityItem(
          icon: Icons.event_available_rounded,
          color: const Color(0xFF4CAF50),
          title: 'New Booking Confirmed',
          subtitle: 'Rahim Ahmed booked AC Servicing',
          time: '2 min ago',
        ),
        _buildActivityItem(
          icon: Icons.person_add_rounded,
          color: const Color(0xFF2196F3),
          title: 'New Customer Joined',
          subtitle: 'Tania Islam registered as a customer',
          time: '18 min ago',
        ),
        _buildActivityItem(
          icon: Icons.storefront_rounded,
          color: const Color(0xFFFF9800),
          title: 'Provider Pending Verification',
          subtitle: 'HomeCare Plus submitted documents',
          time: '45 min ago',
          hasBadge: true,
          badgeLabel: 'Action Needed',
        ),
        _buildActivityItem(
          icon: Icons.payments_rounded,
          color: const Color(0xFF9C27B0),
          title: 'Payout Released',
          subtitle: '৳11,000 transferred to Elite Servicing BD',
          time: '1 hr ago',
        ),
        _buildActivityItem(
          icon: Icons.star_rounded,
          color: const Color(0xFFFFC107),
          title: 'New Review Posted',
          subtitle: 'Customer rated Quick Fix Pro ★ 4.8',
          time: '2 hr ago',
        ),
        _buildActivityItem(
          icon: Icons.block_rounded,
          color: const Color(0xFFD32F2F),
          title: 'Account Suspended',
          subtitle: 'Admin suspended provider ID: P45219',
          time: '3 hr ago',
          isLast: true,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
    bool hasBadge = false,
    String badgeLabel = '',
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline track
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                      width: 1.5, color: Colors.black.withValues(alpha: 0.06)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 6,
                        offset: Offset(0, 3))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87)),
                        ),
                        Text(time,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: Colors.black38)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Colors.black54)),
                    if (hasBadge) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(badgeLabel,
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: color)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87)),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45)),
        ],
      ),
    );
  }

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Profile and Greeting on Left side
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: const ClipOval(
                      child: Icon(Icons.admin_panel_settings_rounded,
                          color: Color(0xFF6950F4), size: 24),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RIPO Admin',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87),
                      ),
                      Text(
                        'Welcome back Admin',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),

              // Notification on Right side
              IconButton(
                icon: const Icon(Icons.notifications_rounded,
                    color: Colors.black87, size: 20),
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: _buildBodyContent(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: Colors.white,
      elevation: 16,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
                icon: Icons.dashboard_rounded, label: 'Overview', index: 0),
            _buildNavItem(
                icon: Icons.people_alt_rounded, label: 'Users', index: 1),
            _buildNavItem(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Finances',
                index: 2),
            _buildNavItem(
                icon: Icons.local_offer_rounded, label: 'Offers', index: 3),
            _buildNavItem(
                icon: Icons.settings_rounded, label: 'Settings', index: 4),
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
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: selected ? const Color(0xFF6950F4) : Colors.black38,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? const Color(0xFF6950F4) : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
