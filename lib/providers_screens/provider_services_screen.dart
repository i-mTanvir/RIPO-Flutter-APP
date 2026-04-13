import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/service_details_screen.dart';
import 'package:ripo/providers_screens/add_service_screen.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  // Mock data for the provider's active services
  final List<Map<String, dynamic>> _myServices = [
    {
      'id': '1',
      'name': 'AC Cooling Problem Repair',
      'category': 'AC Repair',
      'price': '500',
      'originalPrice': '600',
      'duration': '30-45 mins',
      'rating': '4.5',
      'reviews': '24',
      'isActive': true,
      'image': 'lib/media/AC_servicing.png'
    },
    {
      'id': '2',
      'name': 'Deep Chemical House Cleaning',
      'category': 'Cleaning',
      'price': '1200',
      'originalPrice': '1500',
      'duration': '3 Hours',
      'rating': '4.8',
      'reviews': '15',
      'isActive': true,
      'image': 'lib/media/clean_house_offer.png'
    },
    {
      'id': '3',
      'name': 'Circuit Board Repair',
      'category': 'Electronics',
      'price': '800',
      'originalPrice': '800',
      'duration': '1 Hour',
      'rating': '4.2',
      'reviews': '8',
      'isActive': false, // paused
      'image': 'lib/media/TV_servicing.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar( // Optional sticky header style for tab
        backgroundColor: const Color(0xFF6950F4),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Portfolio',
          style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: _myServices.isEmpty 
          ? _buildEmptyState() 
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100, left: 16, right: 16),
              itemCount: _myServices.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(_myServices[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.design_services_outlined, size: 80, color: Colors.black12),
          const SizedBox(height: 16),
          const Text('No Services Found', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(height: 8),
          const Text('Tap the + button below to add your first service.', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    bool isActive = service['isActive'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailsScreen(
              serviceData: service,
              isProviderPreview: true,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header / Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF5F5F5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    service['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.black26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              service['name'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFECEFF1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isActive ? 'ACTIVE' : 'PAUSED',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: isActive ? const Color(0xFF388E3C) : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        service['category'],
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            '৳${service['price']}',
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF6950F4)),
                          ),
                          const Spacer(),
                          Icon(Icons.star_rounded, color: Colors.amber[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${service['rating']} (${service['reviews']})',
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons Divider
          const Divider(height: 1, color: Colors.black12),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    // Toggle Activate/Pause Logic
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(isActive ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded, 
                             size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(
                          isActive ? 'Pause' : 'Activate',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 20, color: Colors.black12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddServiceScreen(serviceData: service),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.edit_outlined, size: 18, color: Colors.black54),
                        SizedBox(width: 6),
                        Text('Edit', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 20, color: Colors.black12),
              Expanded(
                child: InkWell(
                  onTap: () {
                    // Delete Logic
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFD32F2F)),
                        SizedBox(width: 6),
                        Text('Delete', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFD32F2F))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ), // closes Column
    ), // closes child: Container
    ); // closes return GestureDetector
  }
}
