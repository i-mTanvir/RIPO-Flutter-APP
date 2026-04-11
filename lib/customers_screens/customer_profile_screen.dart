import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/edit_profile_screen.dart';
import 'package:ripo/customers_screens/chat_list_screen.dart';
import 'package:ripo/customers_screens/favorite_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  CustomerProfileScreen({super.key});

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
                  _buildMenuCard('General', _generalItems),
                  const SizedBox(height: 20),
                  _buildMenuCard('About Our App', _aboutItems),
                  const SizedBox(height: 24),
                  _buildLogOutButton(),
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
            children: const [
              Text(
                'Tanvir Mahmud',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'tanvirmahmud78@gmail.com',
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
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 15,
              fontWeight: FontWeight.w700,
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
              childAspectRatio: 0.75, // Adjusting aspect ratio to make room for text
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
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
                      color: Color(0xFFF2EFFF), // Very light purple background
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
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
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

  Widget _buildLogOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFF9800), width: 1.2), // Orange border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Log Out',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF9800),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Color(0xFFFF9800), size: 18),
          ],
        ),
      ),
    );
  }
}
