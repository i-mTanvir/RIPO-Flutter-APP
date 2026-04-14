import 'package:flutter/material.dart';
import 'package:ripo/Common_Screens/login_screen.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  static const List<Map<String, dynamic>> _platformItems = [
    {'icon': Icons.percent_rounded, 'label': 'Commission\nRates'},
    {'icon': Icons.category_rounded, 'label': 'Service\nCategories'},
    {'icon': Icons.ads_click_rounded, 'label': 'Banner\nAds'},
    {'icon': Icons.notifications_active_rounded, 'label': 'Broadcast\nAlert'},
    {'icon': Icons.construction_rounded, 'label': 'Maintenance\nMode'},
    {'icon': Icons.verified_user_rounded, 'label': 'Verification\nRules'},
    {'icon': Icons.discount_rounded, 'label': 'Promo\nCodes'},
    {'icon': Icons.bar_chart_rounded, 'label': 'Analytics\nReport'},
  ];

  static const List<Map<String, dynamic>> _accountItems = [
    {'icon': Icons.manage_accounts_rounded, 'label': 'Admin\nRoles'},
    {'icon': Icons.security_rounded, 'label': 'Security\nLogs'},
    {'icon': Icons.password_rounded, 'label': 'Change\nPassword'},
    {'icon': Icons.history_rounded, 'label': 'Audit\nTrail'},
  ];

  static const List<Map<String, dynamic>> _supportItems = [
    {'icon': Icons.help_center_rounded, 'label': 'Admin\nSupport'},
    {'icon': Icons.policy_rounded, 'label': 'Policies'},
    {'icon': Icons.bug_report_rounded, 'label': 'Report\nError'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Scrollable Content ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                _buildStatsBanner(),
                const SizedBox(height: 20),
                _buildMenuCard(context, 'Platform Controls', _platformItems),
                const SizedBox(height: 20),
                _buildMenuCard(context, 'Account & Security', _accountItems),
                const SizedBox(height: 20),
                _buildMenuCard(context, 'Help & Resources', _supportItems),
                const SizedBox(height: 24),
                _buildLogOutButton(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Stats Banner (purple gradient, matching provider style) ──
  Widget _buildStatsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6950F4), Color(0xFF8C7AF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x336950F4), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Users', '12.4K', Icons.groups_rounded, Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem('Providers', '850', Icons.storefront_rounded, Colors.amber),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem('Revenue', '৳145K', Icons.toll_rounded, const Color(0xFF00E676)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70)),
      ],
    );
  }

  // ── Menu Card with 4-column icon grid (matching provider profile exactly) ──
  Widget _buildMenuCard(BuildContext context, String title, List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
              childAspectRatio: 0.65,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2EFFF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: const Color(0xFF6950F4),
                        size: 19,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Log Out Button (matching provider profile exactly) ──
  Widget _buildLogOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: Color(0xFFD32F2F), size: 20),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
            ),
          ],
        ),
      ),
    );
  }
}
