import 'package:flutter/material.dart';
import 'package:ripo/admin_screens/admin_customer_details_screen.dart';
import 'package:ripo/admin_screens/admin_provider_details_screen.dart';
import 'package:ripo/core/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<_AdminUsersPayload> _usersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _usersFuture = _loadUsers();
  }

  Future<_AdminUsersPayload> _loadUsers() async {
    final results = await Future.wait<dynamic>([
      AdminService.fetchCustomers(),
      AdminService.fetchProviders(),
    ]);

    return _AdminUsersPayload(
      customers: results[0] as List<AdminCustomerListItem>,
      providers: results[1] as List<AdminProviderListItem>,
    );
  }

  Future<void> _refreshUsers() async {
    final nextFuture = _loadUsers();
    setState(() {
      _usersFuture = nextFuture;
    });
    await nextFuture;
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
                border: Border.all(
                    color: const Color(0xFF6950F4).withValues(alpha: 0.5)),
              ),
              labelColor: const Color(0xFF6950F4),
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
              unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
              tabs: const [
                Tab(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.person_rounded, size: 16),
                      SizedBox(width: 8),
                      Text('Customers')
                    ])),
                Tab(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Icon(Icons.storefront_rounded, size: 16),
                      SizedBox(width: 8),
                      Text('Providers')
                    ])),
              ],
            ),
          ),
        ),

        // ── Tab Content ──
        Expanded(
          child: FutureBuilder<_AdminUsersPayload>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorState();
              }

              final data = snapshot.data;
              if (data == null) {
                return _buildErrorState();
              }

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildCustomersList(data.customers),
                  _buildProvidersList(data.providers),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Customers List ──

  Widget _buildCustomersList(List<AdminCustomerListItem> customers) {
    if (customers.isEmpty) {
      return _buildEmptyState('No customers found yet.');
    }

    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: customers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final customer = customers[index];
          return _buildUserCard(
            name: customer.fullName,
            subtitle: customer.email ?? customer.phone ?? 'No contact info',
            avatarIcon: Icons.person_rounded,
            avatarColor: const Color(0xFF2196F3),
            badgeText: customer.isActive ? 'Active' : 'Inactive',
            badgeColor:
                customer.isActive ? const Color(0xFF4CAF50) : Colors.black45,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminCustomerDetailsScreen(
                    customerId: customer.id,
                    name: customer.fullName,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── Providers List ──

  Widget _buildProvidersList(List<AdminProviderListItem> providers) {
    if (providers.isEmpty) {
      return _buildEmptyState('No providers found yet.');
    }

    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: providers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final provider = providers[index];
          final statusLabel = provider.isVerified
              ? 'Verified'
              : _statusLabel(provider.verificationStatus);
          final badgeColor = provider.isVerified
              ? const Color(0xFF2196F3)
              : const Color(0xFFFF9800);

          return _buildUserCard(
            name: provider.businessName,
            subtitle: provider.ownerName ?? provider.fullName,
            avatarIcon: Icons.home_repair_service_rounded,
            avatarColor: const Color(0xFFFF9800),
            badgeText: provider.isActive ? statusLabel : 'Inactive',
            badgeColor: provider.isActive ? badgeColor : Colors.black45,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminProviderDetailsScreen(
                    providerId: provider.id,
                    businessName: provider.businessName,
                  ),
                ),
              );
            },
          );
        },
      ),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4))
          ],
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
                      Expanded(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: badgeColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Action Button
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.black26, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Could not load users right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _refreshUsers,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return RefreshIndicator(
      onRefresh: _refreshUsers,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 220,
            child: Center(
              child: Text(
                message,
                style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 13, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String rawStatus) {
    if (rawStatus.isEmpty) {
      return 'Pending';
    }
    final normalized = rawStatus.replaceAll('_', ' ');
    return normalized[0].toUpperCase() + normalized.substring(1);
  }
}

class _AdminUsersPayload {
  const _AdminUsersPayload({
    required this.customers,
    required this.providers,
  });

  final List<AdminCustomerListItem> customers;
  final List<AdminProviderListItem> providers;
}
