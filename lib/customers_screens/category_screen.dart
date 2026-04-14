import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/search_screen.dart';

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});

  final List<Map<String, dynamic>> _appliances = [
    {'icon': Icons.ac_unit_rounded, 'name': 'AC Repair', 'bg': const Color(0xFFE8F4FD), 'color': const Color(0xFF4285F4)},
    {'icon': Icons.kitchen_rounded, 'name': 'Refrigerator', 'bg': const Color(0xFFFDE8F3), 'color': const Color(0xFFE91E63)},
    {'icon': Icons.tv_rounded, 'name': 'TV Repair', 'bg': const Color(0xFFE8FDF0), 'color': const Color(0xFF34A853)},
    {'icon': Icons.microwave_rounded, 'name': 'Microwave', 'bg': const Color(0xFFFEF3E8), 'color': const Color(0xFFF39C12)},
    {'icon': Icons.local_laundry_service_rounded, 'name': 'Washing\nMachine', 'bg': const Color(0xFFF2EFFF), 'color': const Color(0xFF6950F4)},
    {'icon': Icons.water_drop_rounded, 'name': 'Water\nPurifier', 'bg': const Color(0xFFE0FAFA), 'color': const Color(0xFF00BFA5)},
  ];

  final List<Map<String, dynamic>> _maintenance = [
    {'icon': Icons.plumbing_rounded, 'name': 'Plumber', 'bg': const Color(0xFFE8F4FD), 'color': const Color(0xFF4285F4)},
    {'icon': Icons.electrical_services_rounded, 'name': 'Electrician', 'bg': const Color(0xFFFEF3E8), 'color': const Color(0xFFF39C12)},
    {'icon': Icons.handyman_rounded, 'name': 'Carpenter', 'bg': const Color(0xFFE8F4FD), 'color': const Color(0xFF4285F4)},
    {'icon': Icons.format_paint_rounded, 'name': 'Painter', 'bg': const Color(0xFFFDE8F3), 'color': const Color(0xFFE91E63)},
  ];

  final List<Map<String, dynamic>> _cleaning = [
    {'icon': Icons.cleaning_services_rounded, 'name': 'Full Home', 'bg': const Color(0xFFF2EFFF), 'color': const Color(0xFF6950F4)},
    {'icon': Icons.chair_rounded, 'name': 'Sofa Clean', 'bg': const Color(0xFFE8FDF0), 'color': const Color(0xFF34A853)},
    {'icon': Icons.bathtub_rounded, 'name': 'Bathroom', 'bg': const Color(0xFFE0FAFA), 'color': const Color(0xFF00BFA5)},
    {'icon': Icons.pest_control_rounded, 'name': 'Pest\nControl', 'bg': const Color(0xFFFEF3E8), 'color': const Color(0xFFF39C12)},
  ];

  void _routeToSearch(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9FB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    _buildSectionTitle('Appliance Repair'),
                    const SizedBox(height: 16),
                    _buildCategoryGrid(context, _appliances),
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle('Home Maintenance'),
                    const SizedBox(height: 16),
                    _buildCategoryGrid(context, _maintenance),
                    const SizedBox(height: 32),
                    
                    _buildSectionTitle('Cleaning & Pest Control'),
                    const SizedBox(height: 16),
                    _buildCategoryGrid(context, _cleaning),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB8A8F8), Color(0xFFE8D8FF)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explore Categories',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Find exactly what you need with our organized service hubs.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF6950F4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<Map<String, dynamic>> items) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => _routeToSearch(context), // Route dynamically
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item['bg'],
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (item['color'] as Color).withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'],
                  size: 22,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                item['name'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
