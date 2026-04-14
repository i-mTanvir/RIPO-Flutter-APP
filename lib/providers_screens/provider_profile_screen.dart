import 'package:flutter/material.dart';
import 'package:ripo/Common_Screens/login_screen.dart';
import 'package:ripo/customers_screens/chat_list_screen.dart';
import 'package:ripo/providers_screens/provider_wallet_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  final VoidCallback onBusinessProfileTap;
  final VoidCallback onScheduleTap;

  ProviderProfileScreen({super.key, required this.onBusinessProfileTap, required this.onScheduleTap});

  final List<Map<String, dynamic>> _generalItems = [
    {'icon': Icons.storefront_rounded, 'label': 'Business\nProfile'},
    {'icon': Icons.calendar_month_rounded, 'label': 'Working\nSchedule'},
    {'icon': Icons.people_outline_rounded, 'label': 'My Staff'},
    {'icon': Icons.chat_bubble_rounded, 'label': 'Messages'},
    {'icon': Icons.star_half_rounded, 'label': 'Reviews'},
    {'icon': Icons.insights_rounded, 'label': 'Performance'},
    {'icon': Icons.account_balance_wallet, 'label': 'My Wallet'},
    {'icon': Icons.subscriptions_outlined, 'label': 'My Plan'},
    {'icon': Icons.map_outlined, 'label': 'Service Area'},
    {'icon': Icons.verified_user_outlined, 'label': 'Documents'},
    {'icon': Icons.settings, 'label': 'Settings'},
  ];

  final List<Map<String, dynamic>> _supportItems = [
    {'icon': Icons.support_agent_rounded, 'label': 'Partner\nSupport'},
    {'icon': Icons.article_outlined, 'label': 'Policies'},
    {'icon': Icons.menu_book_rounded, 'label': 'Provider\nGuide'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F4F8),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _buildStatsBanner(),
                  const SizedBox(height: 20),
                  _buildMenuCard('Business Management', _generalItems),
                  const SizedBox(height: 20),
                  _buildMenuCard('Help & Resources', _supportItems),
                  const SizedBox(height: 24),
                  _buildLogOutButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24), // Accounts for status bar
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6950F4), width: 2),
                  color: const Color(0xFFE8F4FD),
                  image: const DecorationImage(
                    image: AssetImage('lib/media/clean_house_offer.png'), // Mock profile picture
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFF388E3C), shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Elite Servicing BD',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.verified, color: Color(0xFF2196F3), size: 16),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Shaidul Islam • ID: #P45210',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

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
          _buildStatItem('Rating', '4.8', Icons.star_rounded, Colors.amber),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem('Jobs', '124+', Icons.task_alt_rounded, Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem('Level', 'Pro', Icons.military_tech_rounded, const Color(0xFFFFD700)),
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

  Widget _buildMenuCard(String title, List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 20,
              childAspectRatio: 0.75,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (item['label'] == 'Business\nProfile') {
                    onBusinessProfileTap();
                  } else if (item['label'] == 'Working\nSchedule') {
                    onScheduleTap();
                  } else if (item['label'] == 'My Wallet') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProviderWalletScreen(),
                      ),
                    );
                  } else if (item['label'] == 'Messages') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatListScreen(),
                      ),
                    );
                  }
                  // Handle other navigations
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2EFFF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: const Color(0xFF6950F4),
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
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
          side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5), // Red border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: Color(0xFFD32F2F), size: 20),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD32F2F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
