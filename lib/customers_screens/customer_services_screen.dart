import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/service_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerServicesScreen extends StatefulWidget {
  const CustomerServicesScreen({super.key});

  @override
  State<CustomerServicesScreen> createState() => _CustomerServicesScreenState();
}

class _CustomerServicesScreenState extends State<CustomerServicesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _services = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final client = Supabase.instance.client;
    try {
      final serviceRows = await client
          .from('services')
          .select('id, name, regular_price, offer_price, created_at')
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 12));

      final services = List<Map<String, dynamic>>.from(serviceRows);
      final serviceIds = services.map((row) => row['id'] as String).toList();

      final imageByServiceId = <String, String>{};
      if (serviceIds.isNotEmpty) {
        final mediaRows = await client
            .from('service_media')
            .select('service_id, file_url, is_cover, sort_order')
            .inFilter('service_id', serviceIds)
            .order('is_cover', ascending: false)
            .order('sort_order', ascending: true)
            .timeout(const Duration(seconds: 12));

        final media = List<Map<String, dynamic>>.from(mediaRows);
        for (final row in media) {
          final serviceId = row['service_id'] as String?;
          final fileUrl = row['file_url'] as String?;
          if (serviceId == null || fileUrl == null || fileUrl.isEmpty) continue;
          imageByServiceId.putIfAbsent(serviceId, () => fileUrl);
        }
      }

      final mapped = services.map((s) {
        final id = s['id'] as String;
        final name = (s['name'] as String?) ?? 'Service';
        final regular = (s['regular_price'] as num?)?.toDouble() ?? 0;
        final offer = (s['offer_price'] as num?)?.toDouble();
        final hasDiscount = offer != null && offer > 0 && offer < regular;
        final discountPct =
            hasDiscount ? (((regular - offer) / regular) * 100).round() : null;

        return <String, dynamic>{
          'id': id,
          'name': name,
          'discount': hasDiscount ? '$discountPct% OFF' : 'NEW',
          'price': hasDiscount ? offer.toInt() : regular.toInt(),
          'originalPrice': hasDiscount ? regular.toInt() : null,
          'rating': 0.0,
          'image': imageByServiceId[id] ?? '',
          'isFavorite': false,
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _services = mapped;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load services.')),
      );
    }
  }

  void _openDetails(Map<String, dynamic> service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsScreen(serviceData: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9FB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _services.isEmpty
                    ? const Center(
                        child: Text(
                          'No services found.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            color: Colors.black45,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadServices,
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _services.length,
                          itemBuilder: (_, i) =>
                              _buildServiceCard(_services[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Services',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: _loadServices,
                icon: const Icon(Icons.refresh_rounded, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> s) {
    return GestureDetector(
      onTap: () => _openDetails(s),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x0F000000)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color(0xFFF5F5F5),
                    child: (s['image'] as String).isNotEmpty
                        ? Image.network(
                            s['image'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.image_not_supported_outlined,
                                  color: Colors.black26),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.image_outlined,
                                color: Colors.black26),
                          ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xE6FFFFFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s['discount'] as String,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s['name'] as String,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BDT ${s['price']}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                s['rating'].toString(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            s['isFavorite'] = !(s['isFavorite'] as bool);
                          });
                        },
                        child: Icon(
                          (s['isFavorite'] as bool)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: const Color(0xFF4285F4),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
