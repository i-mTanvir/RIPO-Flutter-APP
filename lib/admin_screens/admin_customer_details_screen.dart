// lib\admin_screens\admin_customer_details_screen.dart
import 'package:flutter/material.dart';
import 'package:ripo/core/admin_service.dart';

class AdminCustomerDetailsScreen extends StatefulWidget {
  final String customerId;
  final String name;

  const AdminCustomerDetailsScreen({
    super.key,
    required this.customerId,
    required this.name,
  });

  @override
  State<AdminCustomerDetailsScreen> createState() =>
      _AdminCustomerDetailsScreenState();
}

class _AdminCustomerDetailsScreenState
    extends State<AdminCustomerDetailsScreen> {
  late Future<AdminCustomerDetailsData> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = AdminService.fetchCustomerDetails(widget.customerId);
  }

  Future<void> _reload() async {
    final nextFuture = AdminService.fetchCustomerDetails(widget.customerId);
    setState(() {
      _detailsFuture = nextFuture;
    });
    await nextFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Customer Overview',
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
        ),
      ),
      body: FutureBuilder<AdminCustomerDetailsData>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState();
          }

          final details = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _reload,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(details),
                  const SizedBox(height: 24),
                  _buildActionButtons(details),
                  const SizedBox(height: 24),
                  _buildStatsRow(details),
                  const SizedBox(height: 32),
                  _buildHistorySection(details),
                  const SizedBox(height: 48),
                  _buildDangerZone(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
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
              'Failed to load customer details.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _reload,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Profile Header ──

  Widget _buildProfileHeader(AdminCustomerDetailsData details) {
    final contactParts = <String>[];
    if (details.email != null) {
      contactParts.add(details.email!);
    }
    if (details.phone != null) {
      contactParts.add(details.phone!);
    }
    if (details.createdAt != null) {
      contactParts.add('Joined ${_formatDate(details.createdAt!)}');
    }

    final badgeColor =
        details.isActive ? const Color(0xFF4CAF50) : const Color(0xFF757575);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.person_rounded,
                  size: 44, color: Color(0xFF1976D2)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2)),
              child: Text(details.isActive ? 'Active' : 'Inactive',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(details.fullName,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87)),
        const SizedBox(height: 4),
        Text(
          contactParts.isEmpty
              ? 'No contact information'
              : contactParts.join(' • '),
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54),
        ),
      ],
    );
  }

  // ── Communication Actions ──

  Widget _buildActionButtons(AdminCustomerDetailsData details) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          Icons.call_rounded,
          'Call',
          const Color(0xFF4CAF50),
          onTap: () {
            final phone = details.phone;
            _showSnack(
                phone == null ? 'No phone number available.' : 'Phone: $phone');
          },
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          Icons.chat_bubble_rounded,
          'Message',
          const Color(0xFF2196F3),
          onTap: () {
            final target = details.email ?? details.phone;
            _showSnack(target == null
                ? 'No contact channel available.'
                : 'Contact: $target');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }

  // ── Metrics Bar ──

  Widget _buildStatsRow(AdminCustomerDetailsData details) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: _buildStatItem('Total Taken', '${details.totalBookings}',
                  const Color(0xFF6950F4))),
          Container(width: 1, height: 40, color: Colors.black12),
          Expanded(
              child: _buildStatItem('Pending', '${details.pendingBookings}',
                  const Color(0xFFFF9800))),
          Container(width: 1, height: 40, color: Colors.black12),
          Expanded(
              child: _buildStatItem('Cancelled', '${details.cancelledBookings}',
                  const Color(0xFFF44336))),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black45)),
      ],
    );
  }

  // ── History Tracking ──

  Widget _buildHistorySection(AdminCustomerDetailsData details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Service History',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: details.recentBookings.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'No service history yet.',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.black54),
                  ),
                )
              : Column(
                  children:
                      List.generate(details.recentBookings.length, (index) {
                    final booking = details.recentBookings[index];
                    return Column(
                      children: [
                        _buildHistoryRow(booking),
                        if (index != details.recentBookings.length - 1)
                          const Divider(height: 24, color: Colors.black12),
                      ],
                    );
                  }),
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryRow(AdminBookingPreview booking) {
    final badgeColor = _statusColor(booking.status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.serviceName,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
            const SizedBox(height: 4),
            Text(booking.providerName,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_formatCurrency(booking.totalAmount),
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6950F4))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(_statusLabel(booking.status),
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: badgeColor)),
            ),
          ],
        ),
      ],
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatCurrency(double amount) {
    final hasFraction = amount != amount.roundToDouble();
    return '৳${amount.toStringAsFixed(hasFraction ? 2 : 0)}';
  }

  String _statusLabel(String rawStatus) {
    if (rawStatus.isEmpty) {
      return 'Pending';
    }

    final normalized = rawStatus.replaceAll('_', ' ');
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'pending':
      case 'accepted':
      case 'in_progress':
        return const Color(0xFFFF9800);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFD32F2F);
      default:
        return Colors.black45;
    }
  }

  String _formatDate(DateTime dateTime) {
    const months = [
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
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.year}';
  }

  // ── Danger Zone ──

  Widget _buildDangerZone() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFD32F2F), size: 20),
              SizedBox(width: 8),
              Text('Danger Zone',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD32F2F))),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
              'Banning this customer will instantly restrict their access to the platform layout and prevent future bookings.',
              style: TextStyle(
                  fontFamily: 'Inter', fontSize: 12, color: Color(0xFFC62828))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Ban Customer Account',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
