import 'package:flutter/material.dart';

class AdminProviderDetailsScreen extends StatefulWidget {
  final String businessName;

  const AdminProviderDetailsScreen({super.key, required this.businessName});

  @override
  State<AdminProviderDetailsScreen> createState() => _AdminProviderDetailsScreenState();
}

class _AdminProviderDetailsScreenState extends State<AdminProviderDetailsScreen> {
  bool _isVerified = true;

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
          style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 32),
            _buildVerificationControl(),
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 32),
            _buildReviewsSection(),
            const SizedBox(height: 48),
            _buildDangerZone(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Profile Header ──

  Widget _buildProfileHeader() {
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
                boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: const Icon(Icons.home_repair_service_rounded, size: 40, color: Color(0xFFFF9800)),
            ),
            if (_isVerified)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFF2196F3), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(widget.businessName, style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black87)),
        const SizedBox(height: 4),
        const Text('Owner: Shaidul Islam • Provider ID: P45210', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54)),
      ],
    );
  }

  // ── Communication Actions ──

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(Icons.call_rounded, 'Call', const Color(0xFF4CAF50)),
        const SizedBox(width: 16),
        _buildActionButton(Icons.chat_bubble_rounded, 'Message', const Color(0xFF2196F3)),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {},
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
            Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }

  // ── Verification Toggle ──
  
  Widget _buildVerificationControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_rounded, color: _isVerified ? const Color(0xFF2196F3) : Colors.black38, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Platform Verification', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                  Text(
                    _isVerified ? 'Documents Approved' : 'Action Required',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: _isVerified ? const Color(0xFF2196F3) : Colors.black45),
                  )
                ],
              ),
            ],
          ),
          Switch(
            value: _isVerified,
            activeThumbColor: const Color(0xFF2196F3),
            onChanged: (val) {
              setState(() {
                _isVerified = val;
              });
            },
          )
        ],
      ),
    );
  }

  // ── Metrics Bar ──

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _buildStatItem('Completed', '124', const Color(0xFF6950F4))),
          Container(width: 1, height: 40, color: Colors.black12),
          Expanded(child: _buildStatItem('Active Gigs', '14', const Color(0xFFFF9800))),
          Container(width: 1, height: 40, color: Colors.black12),
          Expanded(child: _buildStatItem('Avg Rating', '4.8', const Color(0xFF4CAF50))),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black45)),
      ],
    );
  }

  // ── History Tracking ──

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Feedback', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              _buildReviewRow('John Doe', 'Great servicing. Arrived perfectly on time!', 5),
              const Divider(height: 24, color: Colors.black12),
              _buildReviewRow('Sarah Khan', 'A bit pricey but fixed the TV issues.', 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String customer, String comment, int rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(customer, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: const Color(0xFFFFC107),
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(comment, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, height: 1.4, color: Colors.black54)),
      ],
    );
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
              Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 20),
              SizedBox(width: 8),
              Text('Danger Zone', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFD32F2F))),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Suspending this provider will immediately pull all of their active services offline and freeze their platform payouts.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFFC62828))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Suspend Provider License', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}
