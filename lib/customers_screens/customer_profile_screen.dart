import 'package:flutter/material.dart';
import 'package:ripo/Common_Screens/login_screen.dart';
import 'package:ripo/customers_screens/edit_profile_screen.dart';
import 'package:ripo/customers_screens/chat_list_screen.dart';
import 'package:ripo/customers_screens/favorite_screen.dart';
import 'package:ripo/providers_screens/provider_wallet_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  String _userFullName = 'Loading...';
  String _userEmail = 'Loading...';

  final List<Map<String, dynamic>> _generalItems = [
    {'icon': Icons.person, 'label': 'My Profile'},
    {'icon': Icons.edit, 'label': 'My Post'},
    {'icon': Icons.chat_bubble_rounded, 'label': 'Message'},
    {'icon': Icons.local_activity, 'label': 'Coupon'},
    {'icon': Icons.percent_rounded, 'label': 'Offers'},
    {'icon': Icons.account_balance_wallet, 'label': 'My Wallet'},
    {'icon': Icons.favorite, 'label': 'Favourite'},
    {'icon': Icons.location_on, 'label': 'Service Area'},
    {'icon': Icons.engineering, 'label': 'Become a\nProvider'},
    {'icon': Icons.reply_rounded, 'label': 'Refer to\nEarned'},
    {'icon': Icons.settings, 'label': 'General\nSetting'},
  ];

  final List<Map<String, dynamic>> _aboutItems = [
    {'icon': Icons.info, 'label': 'About us'},
    {'icon': Icons.security, 'label': 'Privacy &\nPolicy'},
    {'icon': Icons.description, 'label': 'Terms &\nCondition'},
    {'icon': Icons.support_agent, 'label': 'Help &\nSupport'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    try {
      final profile = await client
          .from('profiles')
          .select('full_name, email')
          .eq('id', userId)
          .maybeSingle();

      if (!mounted) return;

      if (profile != null) {
        setState(() {
          _userFullName = (profile['full_name'] as String?)?.trim() ?? 'User';
          _userEmail = (profile['email'] as String?)?.trim() ?? '';
        });
      } else {
        setState(() {
          _userFullName = 'User';
          _userEmail = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userFullName = 'User';
          _userEmail = '';
        });
      }
    }
  }

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
                  _buildMenuCard('General', _generalItems),
                  const SizedBox(height: 20),
                  _buildMenuCard('About Our App', _aboutItems),
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
      padding:
          const EdgeInsets.fromLTRB(16, 60, 16, 24), // Accounts for status bar
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 2),
              color: const Color(0xFFE8F4FD),
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.black54),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userFullName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userEmail,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
            ],
          )
        ],
      ),
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
              childAspectRatio:
                  0.75, // Adjusting aspect ratio to make room for text
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (item['label'] == 'My Profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  } else if (item['label'] == 'Message') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatListScreen(),
                      ),
                    );
                  } else if (item['label'] == 'My Wallet') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProviderWalletScreen(),
                      ),
                    );
                  } else if (item['label'] == 'Favourite') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoriteScreen(),
                      ),
                    );
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color:
                            Color(0xFFF2EFFF), // Very light purple background
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: const Color(0xFF6950F4), // Primary purple
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
          side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
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
        boxShadow: const [
          BoxShadow(
              color: Color(0x336950F4), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
              'Bookings', '12', Icons.task_alt_rounded, Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem('Points', '250', Icons.stars_rounded, Colors.amber),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStatItem(
              'Tier', 'Gold', Icons.shield_rounded, const Color(0xFFFFD700)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Text(value,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white70)),
      ],
    );
  }
}
