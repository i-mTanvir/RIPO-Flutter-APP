import 'package:flutter/material.dart';
import 'package:ripo/admin_screens/admin_customer_details_screen.dart';
import 'package:ripo/admin_screens/admin_provider_details_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab Bar ──
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: const Color(0xFF6950F4).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF6950F4).withValues(alpha: 0.5)),
              ),
              labelColor: const Color(0xFF6950F4),
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.person_rounded, size: 16), SizedBox(width: 8), Text('Customers')])),
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.storefront_rounded, size: 16), SizedBox(width: 8), Text('Providers')])),
              ],
            ),
          ),
        ),

        // ── Tab Content ──
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCustomersList(),
              _buildProvidersList(),
            ],
          ),
        ),
      ],
    );
  }

  // ── Customers List ──

  Widget _buildCustomersList() {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildUserCard(
          name: 'Customer Demo $index',
          subtitle: 'customer$index@ripo.com',
          avatarIcon: Icons.person_rounded,
          avatarColor: const Color(0xFF2196F3),
          badgeText: 'Active',
          badgeColor: const Color(0xFF4CAF50),
          isProvider: false,
        );
      },
    );
  }

  // ── Providers List ──

  Widget _buildProvidersList() {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildUserCard(
          name: 'Elite Services $index',
          subtitle: 'Shaidul Islam • ID: P4521$index',
          avatarIcon: Icons.home_repair_service_rounded,
          avatarColor: const Color(0xFFFF9800),
          badgeText: index == 1 ? 'Pending' : 'Verified',
          badgeColor: index == 1 ? const Color(0xFFFF9800) : const Color(0xFF2196F3),
          isProvider: true,
        );
      },
    );
  }

  // ── Reusable Component ──

  Widget _buildUserCard({
    required String name,
    required String subtitle,
    required IconData avatarIcon,
    required Color avatarColor,
    required String badgeText,
    required Color badgeColor,
    required bool isProvider,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isProvider) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminProviderDetailsScreen(businessName: name)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AdminCustomerDetailsScreen(name: name)));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4))],
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(avatarIcon, color: avatarColor, size: 22),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        badgeText,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700, color: badgeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Action Button
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
                // Inline options
            },
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          )
        ],
      ),
      ),
    );
  }
}
