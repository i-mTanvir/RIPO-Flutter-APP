import 'package:flutter/material.dart';

class AdminFinanceScreen extends StatelessWidget {
  const AdminFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRevenueBanner(),
          const SizedBox(height: 16),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildSectionTitle('Pending Payouts'),
          const SizedBox(height: 12),
          _buildPendingPayoutCard('Elite Servicing BD', 'Shaidul Islam',
              '৳ 12,400', '3 jobs completed'),
          const SizedBox(height: 10),
          _buildPendingPayoutCard(
              'Quick Fix Pro', 'Rafiul Hasan', '৳ 8,750', '2 jobs completed'),
          const SizedBox(height: 10),
          _buildPendingPayoutCard(
              'HomeCare Plus', 'Nadia Akter', '৳ 5,200', '1 job completed'),
          const SizedBox(height: 24),
          _buildSectionTitle('Recent Transactions'),
          const SizedBox(height: 12),
          _buildTransactionItem(
              'Commission – AC Service', '+৳ 1,200', 'Apr 13, 2026', true),
          _buildTransactionItem(
              'Payout – Elite BD', '-৳ 11,000', 'Apr 12, 2026', false),
          _buildTransactionItem(
              'Commission – Plumbing Fix', '+৳ 500', 'Apr 12, 2026', true),
          _buildTransactionItem(
              'Payout – Quick Fix Pro', '-৳ 7,400', 'Apr 11, 2026', false),
          _buildTransactionItem(
              'Commission – House Cleaning', '+৳ 800', 'Apr 11, 2026', true),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Revenue Banner ──
  Widget _buildRevenueBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6950F4), Color(0xFF8C7AF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x406950F4), blurRadius: 14, offset: Offset(0, 6))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(Icons.account_balance_wallet_rounded,
                size: 100, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Platform Revenue',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70)),
              const SizedBox(height: 8),
              const Text('৳ 1,45,200',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100)),
                    child: const Row(
                      children: [
                        Icon(Icons.trending_up_rounded,
                            color: Color(0xFF00E676), size: 14),
                        SizedBox(width: 4),
                        Text('+18% this month',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  // ── Quick Stats ──
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
            child: _buildQuickStat('Commission\nEarned', '৳ 21.4K',
                Icons.toll_rounded, const Color(0xFF4CAF50))),
        const SizedBox(width: 10),
        Expanded(
            child: _buildQuickStat('Pending\nPayouts', '৳ 26.3K',
                Icons.pending_actions_rounded, const Color(0xFFFF9800))),
        const SizedBox(width: 10),
        Expanded(
            child: _buildQuickStat('Total\nJobs', '342', Icons.handyman_rounded,
                const Color(0xFF2196F3))),
      ],
    );
  }

  Widget _buildQuickStat(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black87));
  }

  // ── Pending Payout Card ──
  Widget _buildPendingPayoutCard(
      String business, String owner, String amount, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.storefront_rounded,
                color: Color(0xFFFF9800), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(business,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87)),
                const SizedBox(height: 2),
                Text('$owner • $subtitle',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Colors.black54)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6950F4))),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('Release',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // ── Transaction Item ──
  Widget _buildTransactionItem(
      String title, String amount, String date, bool isIncoming) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isIncoming
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isIncoming
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: isIncoming
                    ? const Color(0xFF388E3C)
                    : const Color(0xFFD32F2F),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
                  Text(date,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Colors.black45)),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isIncoming
                    ? const Color(0xFF388E3C)
                    : const Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
