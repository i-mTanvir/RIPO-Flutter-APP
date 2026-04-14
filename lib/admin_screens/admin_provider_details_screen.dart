import 'package:flutter/material.dart';
import 'package:ripo/core/admin_service.dart';

class AdminProviderDetailsScreen extends StatefulWidget {
  final String providerId;
  final String businessName;

  const AdminProviderDetailsScreen({
    super.key,
    required this.providerId,
    required this.businessName,
  });

  @override
  State<AdminProviderDetailsScreen> createState() =>
      _AdminProviderDetailsScreenState();
}

class _AdminProviderDetailsScreenState
    extends State<AdminProviderDetailsScreen> {
  late Future<AdminProviderDetailsData> _detailsFuture;
  bool? _isVerified;
  bool _isUpdatingVerification = false;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<AdminProviderDetailsData> _loadDetails() async {
    final details = await AdminService.fetchProviderDetails(widget.providerId);
    _isVerified ??= details.isVerified;
    return details;
  }

  Future<void> _reload() async {
    _isVerified = null;
    final nextFuture = _loadDetails();
    setState(() {
      _detailsFuture = nextFuture;
    });
    await nextFuture;
  }

  Future<void> _toggleVerification(bool value) async {
    final previous = _isVerified ?? false;
    setState(() {
      _isVerified = value;
      _isUpdatingVerification = true;
    });

    try {
      await AdminService.updateProviderVerificationStatus(
        userId: widget.providerId,
        isVerified: value,
      );
      if (!mounted) {
        return;
      }
      _showSnack(value ? 'Provider verified.' : 'Provider marked as pending.');
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isVerified = previous;
      });
      _showSnack('Failed to update verification status.');
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingVerification = false;
        });
      }
    }
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
          'Provider Overview',
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87),
        ),
      ),
      body: FutureBuilder<AdminProviderDetailsData>(
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
                  const SizedBox(height: 32),
                  _buildVerificationControl(details),
                  const SizedBox(height: 24),
                  _buildStatsRow(details),
                  const SizedBox(height: 32),
                  _buildReviewsSection(details),
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
              'Failed to load provider details.',
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

  Widget _buildProfileHeader(AdminProviderDetailsData details) {
    final isVerified = _isVerified ?? details.isVerified;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 10,
                      offset: Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.home_repair_service_rounded,
                  size: 40, color: Color(0xFFFF9800)),
            ),
            if (isVerified)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.verified_rounded,
                    size: 14, color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(details.businessName,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87)),
        const SizedBox(height: 4),
        Text(
          'Owner: ${details.ownerName ?? details.fullName} • Provider ID: ${_shortProviderId(details.id)}',
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

  Widget _buildActionButtons(AdminProviderDetailsData details) {
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

  // ── Verification Toggle ──

  Widget _buildVerificationControl(AdminProviderDetailsData details) {
    final isVerified = _isVerified ?? details.isVerified;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_rounded,
                  color: isVerified ? const Color(0xFF2196F3) : Colors.black38,
                  size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Platform Verification',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
                  Text(
                    isVerified
                        ? 'Documents Approved'
                        : 'Status: ${_statusLabel(details.verificationStatus)}',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: isVerified
                            ? const Color(0xFF2196F3)
                            : Colors.black45),
                  )
                ],
              ),
            ],
          ),
          _isUpdatingVerification
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch(
                  value: isVerified,
                  activeThumbColor: const Color(0xFF2196F3),
                  onChanged: _toggleVerification,
                )
        ],
      ),
    );
  }

  // ── Metrics Bar ──

  Widget _buildStatsRow(AdminProviderDetailsData details) {
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
              child: _buildStatItem('Completed', '${details.completedJobs}',
                  const Color(0xFF6950F4))),
          Container(width: 1, height: 40, color: Colors.black12),
          Expanded(
              child: _buildStatItem('Active Gigs', '${details.activeGigs}',
                  const Color(0xFFFF9800))),
          Container(width: 1, height: 40, color: Colors.black12),
          Expanded(
              child: _buildStatItem(
                  'Avg Rating',
                  details.ratingAvg.toStringAsFixed(1),
                  const Color(0xFF4CAF50))),
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

  Widget _buildReviewsSection(AdminProviderDetailsData details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Feedback',
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
          child: details.recentReviews.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'No feedback yet.',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.black54),
                  ),
                )
              : Column(
                  children:
                      List.generate(details.recentReviews.length, (index) {
                    final review = details.recentReviews[index];
                    return Column(
                      children: [
                        _buildReviewRow(review),
                        if (index != details.recentReviews.length - 1)
                          const Divider(height: 24, color: Colors.black12),
                      ],
                    );
                  }),
                ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(AdminProviderReviewPreview review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(review.customerName,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xFFFFC107),
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(review.comment ?? 'No comment provided.',
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                height: 1.4,
                color: Colors.black54)),
      ],
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusLabel(String rawStatus) {
    if (rawStatus.isEmpty) {
      return 'Pending';
    }

    final normalized = rawStatus.replaceAll('_', ' ');
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String _shortProviderId(String id) {
    if (id.length <= 8) {
      return id;
    }
    return id.substring(0, 8).toUpperCase();
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
              'Suspending this provider will immediately pull all of their active services offline and freeze their platform payouts.',
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
              child: const Text('Suspend Provider License',
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
