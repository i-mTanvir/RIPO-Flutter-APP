import 'package:flutter/material.dart';

class ProviderJobsScreen extends StatefulWidget {
  const ProviderJobsScreen({super.key});

  @override
  State<ProviderJobsScreen> createState() => _ProviderJobsScreenState();
}

class _ProviderJobsScreenState extends State<ProviderJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsTab(),
              _buildActiveTab(),
              _buildCompletedTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        bottom: false,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            'Job Management',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelColor: const Color(0xFF6950F4),
        unselectedLabelColor: Colors.black45,
        indicatorColor: const Color(0xFF6950F4),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Requests'),
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  // ── Tabs content ─────────────────────────────────────────────────────────

  Widget _buildRequestsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildJobCard(
          status: 'Pending Request',
          statusColor: const Color(0xFFFF8F00),
          statusBgColor: const Color(0xFFFFF3E0),
          name: 'Hasan Ali',
          service: 'Water Filter Installation',
          address: 'Gulshan 2, Dhaka',
          date: 'Tomorrow, 3:00 PM',
          price: '850',
          avatar: Icons.person,
          actionButtons: _buildActionButtons(
            negativeLabel: 'Decline',
            positiveLabel: 'Accept',
            onNegative: () {},
            onPositive: () {},
          ),
        ),
        const SizedBox(height: 16),
        _buildJobCard(
          status: 'Pending Request',
          statusColor: const Color(0xFFFF8F00),
          statusBgColor: const Color(0xFFFFF3E0),
          name: 'Nadia Rahman',
          service: 'Plumbing Service',
          address: 'Banani, Dhaka',
          date: '15 Apr, 10:00 AM',
          price: '1,500',
          avatar: Icons.person_4,
          actionButtons: _buildActionButtons(
            negativeLabel: 'Decline',
            positiveLabel: 'Accept',
            onNegative: () {},
            onPositive: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildJobCard(
          status: 'In Progress',
          statusColor: const Color(0xFF1E88E5),
          statusBgColor: const Color(0xFFE8F4FD),
          name: 'Arif Hossain',
          service: 'TV Repairing Service',
          address: 'Sector 11, Uttara',
          date: 'Today, 11:00 AM - 12:30 PM',
          price: '1,200',
          avatar: Icons.person_2,
          showContactOptions: true,
          actionButtons: _buildActionButtons(
            negativeLabel: 'Cancel Job',
            positiveLabel: 'Mark Completed',
            onNegative: () {},
            onPositive: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildJobCard(
          status: 'Completed',
          statusColor: const Color(0xFF43A047),
          statusBgColor: const Color(0xFFE8F5E9),
          name: 'Selim Reza',
          service: 'AC Servicing',
          address: 'Mirpur 10, Dhaka',
          date: '10 Apr, 4:00 PM',
          price: '2,500',
          avatar: Icons.person,
          isCompleted: true,
        ),
        const SizedBox(height: 16),
        _buildJobCard(
          status: 'Completed',
          statusColor: const Color(0xFF43A047),
          statusBgColor: const Color(0xFFE8F5E9),
          name: 'Sumaiya Akter',
          service: 'House Cleaning',
          address: 'Dhanmondi 27',
          date: '08 Apr, 9:00 AM',
          price: '1,800',
          avatar: Icons.person_3,
          isCompleted: true,
        ),
      ],
    );
  }

  // ── Job Card ─────────────────────────────────────────────────────────────

  Widget _buildJobCard({
    required String status,
    required Color statusColor,
    required Color statusBgColor,
    required String name,
    required String service,
    required String address,
    required String date,
    required String price,
    required IconData avatar,
    bool showContactOptions = false,
    bool isCompleted = false,
    Widget? actionButtons,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                '৳ $price',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // User Info
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F4FD),
                  shape: BoxShape.circle,
                ),
                child: Icon(avatar, color: const Color(0xFF1E88E5), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFF6950F4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (showContactOptions)
                Row(
                  children: [
                    _buildIconButton(Icons.chat_bubble_rounded, const Color(0xFF6950F4)),
                    const SizedBox(width: 8),
                    _buildIconButton(Icons.call_rounded, const Color(0xFF43A047)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 16),

          // Details
          Row(
            children: [
               const Icon(Icons.location_on_rounded, size: 16, color: Colors.black38),
               const SizedBox(width: 8),
               Text(address, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
               const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.black38),
               const SizedBox(width: 8),
               Text(date, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black54)),
            ],
          ),

          // Action Buttons
          if (actionButtons != null) ...[
            const SizedBox(height: 20),
            actionButtons,
          ],

          // Completed Note
          if (isCompleted) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF43A047)),
                const SizedBox(width: 6),
                const Text('Payment Received', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF43A047))),
                const Spacer(),
                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFF8F00)),
                const SizedBox(width: 4),
                const Text('5.0', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildActionButtons({
    required String negativeLabel,
    required String positiveLabel,
    required VoidCallback onNegative,
    required VoidCallback onPositive,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onNegative,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF5252)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(negativeLabel, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFF5252))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onPositive,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6950F4),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(positiveLabel, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
