import 'package:flutter/material.dart';

class ProviderWalletScreen extends StatelessWidget {
  const ProviderWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6950F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'My Wallet',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          _buildTopBalanceBanner(),
          Expanded(
            child: Container(
              color: const Color(0xFFF4F4F8),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWithdrawSection(),
                    const SizedBox(height: 28),
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTransactionHistory(),
                    const SizedBox(height: 100), // padding for bottom nav
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBalanceBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF6950F4),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '৳ 14,500.00',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  label: 'Total Earnings',
                  value: '৳ 42,800',
                  icon: Icons.trending_up_rounded,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _buildMetric(
                  label: 'Pending Clearance',
                  value: '৳ 2,100',
                  icon: Icons.hourglass_top_rounded,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetric(
      {required String label, required String value, required IconData icon}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Withdrawal Method',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Change',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFF6950F4),
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_rounded,
                    color: Color(0xFF6950F4)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Dutch-Bangla Bank',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '**** **** 8291',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6950F4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Withdraw Funds',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    final List<Map<String, dynamic>> transactions = [
      {
        'title': 'Withdrawal to Dutch-Bangla Bank',
        'date': '12 April, 2026',
        'amount': '-৳ 5,000',
        'isIncome': false,
        'status': 'Completed'
      },
      {
        'title': 'AC Servicing (Job #928)',
        'date': '10 April, 2026',
        'amount': '+৳ 1,200',
        'isIncome': true,
        'status': 'Cleared'
      },
      {
        'title': 'House Deep Cleaning (Job #912)',
        'date': '08 April, 2026',
        'amount': '+৳ 2,500',
        'isIncome': true,
        'status': 'Cleared'
      },
      {
        'title': 'TV Board Repair (Job #901)',
        'date': '05 April, 2026',
        'amount': '+৳ 800',
        'isIncome': true,
        'status': 'Cleared'
      },
      {
        'title': 'Withdrawal to bKash',
        'date': '01 April, 2026',
        'amount': '-৳ 10,000',
        'isIncome': false,
        'status': 'Completed'
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isIncome = tx['isIncome'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isIncome
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: isIncome
                      ? const Color(0xFF388E3C)
                      : const Color(0xFFD32F2F),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title'],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tx['date']} • ${tx['status']}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tx['amount'],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isIncome ? const Color(0xFF388E3C) : Colors.black87,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
