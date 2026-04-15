// lib\admin_screens\admin_offers_screen.dart
import 'package:flutter/material.dart';

class AdminOffersScreen extends StatefulWidget {
  const AdminOffersScreen({super.key});

  @override
  State<AdminOffersScreen> createState() => _AdminOffersScreenState();
}

class _AdminOffersScreenState extends State<AdminOffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showActionSheet(String title, bool isCategory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                24, 32, 24, MediaQuery.of(context).viewInsets.bottom + 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manage ${isCategory ? 'Category' : 'Offer'}',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87)),
                const SizedBox(height: 6),
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54)),
                const SizedBox(height: 32),
                _buildBottomSheetButton(Icons.edit_rounded, 'Edit Details',
                    const Color(0xFF2196F3), 'Modify the inner configurations'),
                const SizedBox(height: 16),
                _buildBottomSheetButton(
                    Icons.visibility_off_rounded,
                    'Pull Offline',
                    const Color(0xFFFF9800),
                    'Temporarily hide from the platform'),
                const SizedBox(height: 16),
                _buildBottomSheetButton(
                    Icons.delete_forever_rounded,
                    'Permanently Delete',
                    const Color(0xFFD32F2F),
                    'Irreversible destruction'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetButton(
      IconData icon, String label, Color color, String subtitle) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // Handle Action
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.black45)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.5), size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tab Bar ──
        Container(
          height: 38,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 4))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: const Color(0xFF6950F4),
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x336950F4),
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: 11),
              unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 11),
              tabs: const [
                Tab(text: 'Live Offers'),
                Tab(text: 'Categories'),
              ],
            ),
          ),
        ),

        // ── Tab Content ──
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLiveOffersTab(),
              _buildCategoriesTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ── Offers Tab (Premium Coupon Cards) ──

  Widget _buildLiveOffersTab() {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final titles = ['Eid Special Deal', 'Summer Chill', 'New User Bonus'];
        final sub = [
          '20% OFF all base services',
          '15% OFF AC diagnostics',
          'Flat ৳500 OFF first booking'
        ];
        final gradients = [
          const [Color(0xFF6950F4), Color(0xFF8B75FF)],
          const [Color(0xFF00B4DB), Color(0xFF0083B0)],
          const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
        ];

        return GestureDetector(
          onTap: () => _showActionSheet(titles[index], false),
          child: Container(
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: gradients[index],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: gradients[index][0].withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Stack(
              children: [
                // Background Graphic
                Positioned(
                  right: -10,
                  bottom: -15,
                  child: Icon(Icons.local_offer_rounded,
                      size: 80, color: Colors.white.withValues(alpha: 0.1)),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(100)),
                            child: const Text('ACTIVE',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1)),
                          ),
                          const Icon(Icons.more_horiz_rounded,
                              color: Colors.white, size: 18),
                        ],
                      ),
                      const Spacer(),
                      Text(titles[index],
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(sub[index],
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Categories Tab (Premium Grid) ──

  Widget _buildCategoriesTab() {
    final categoryNames = [
      'AC Repair',
      'Plumbing',
      'Cleaning',
      'Car Wash',
      'Electrical',
      'Painting'
    ];
    final categoryIcons = [
      Icons.ac_unit_rounded,
      Icons.plumbing_rounded,
      Icons.cleaning_services_rounded,
      Icons.local_car_wash_rounded,
      Icons.electrical_services_rounded,
      Icons.format_paint_rounded
    ];
    final categoryColors = [
      const Color(0xFF00BCD4),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF3F51B5),
      const Color(0xFF4CAF50),
      const Color(0xFF9C27B0)
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        final color = categoryColors[index];
        return GestureDetector(
          onTap: () => _showActionSheet(categoryNames[index], true),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: color.withValues(alpha: 0.1), width: 1.2),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 6,
                    offset: Offset(0, 3))
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 4,
                  top: 4,
                  child: Icon(Icons.more_vert_rounded,
                      color: Colors.black26, size: 14),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(categoryIcons[index], color: color, size: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(categoryNames[index],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87)),
                      const SizedBox(height: 1),
                      Text('${index * 15 + 10} Prov.',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: Colors.black45)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
