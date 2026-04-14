import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/booking_schedule.dart';
import 'package:ripo/customers_screens/chat_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? serviceData;
  final bool isProviderPreview;

  const ServiceDetailsScreen({
    super.key,
    this.serviceData,
    this.isProviderPreview = false,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  bool _isFavorite = false;
  Map<String, dynamic> _resolvedServiceData = <String, dynamic>{};
  Map<String, dynamic> _providerData = <String, dynamic>{};
  List<Map<String, dynamic>> _reviews = <Map<String, dynamic>>[];

  final List<String> _tabs = [
    'Overview',
    'Service Variation',
    'Review',
    'FAQs'
  ];

  Map<String, dynamic> get _displayData {
    if (widget.isProviderPreview) {
      return Map<String, dynamic>.from(widget.serviceData ?? const {});
    }
    return _resolvedServiceData;
  }

  @override
  void initState() {
    super.initState();
    _resolvedServiceData =
        Map<String, dynamic>.from(widget.serviceData ?? const {});
    if (!widget.isProviderPreview) {
      _loadServiceDetailsFromDb();
    }
  }

  Future<void> _loadServiceDetailsFromDb() async {
    final serviceId = widget.serviceData?['id'] as String?;
    if (serviceId == null || serviceId.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    final client = Supabase.instance.client;

    try {
      final serviceRow = await client.from('services').select('''
            id,
            provider_id,
            name,
            description,
            variations,
            faqs,
            duration_text,
            regular_price,
            offer_price,
            service_categories(name),
            provider_profiles(
              business_name,
              owner_name,
              rating_avg,
              review_count
            )
          ''').eq('id', serviceId).maybeSingle();

      if (serviceRow == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final mediaRows = await client
          .from('service_media')
          .select('file_url, is_cover, sort_order')
          .eq('service_id', serviceId)
          .order('is_cover', ascending: false)
          .order('sort_order', ascending: true);

      final reviewsRows = await client
          .from('reviews')
          .select('id, customer_id, rating, comment, created_at')
          .eq('service_id', serviceId)
          .order('created_at', ascending: false);

      final media = List<Map<String, dynamic>>.from(mediaRows);
      final reviews = List<Map<String, dynamic>>.from(reviewsRows);

      final image =
          media.isEmpty ? '' : (media.first['file_url'] as String? ?? '');

      final customerIds = reviews
          .map((row) => row['customer_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final customerNameById = <String, String>{};
      if (customerIds.isNotEmpty) {
        final profilesRows = await client
            .from('profiles')
            .select('id, full_name')
            .inFilter('id', customerIds);
        for (final row in List<Map<String, dynamic>>.from(profilesRows)) {
          final id = row['id'] as String?;
          final fullName = (row['full_name'] as String?)?.trim() ?? '';
          if (id != null) {
            customerNameById[id] = fullName;
          }
        }
      }

      final providerId = serviceRow['provider_id'] as String?;
      String providerProfileName = '';
      if (providerId != null && providerId.isNotEmpty) {
        final providerProfileRow = await client
            .from('profiles')
            .select('full_name')
            .eq('id', providerId)
            .maybeSingle();
        providerProfileName =
            (providerProfileRow?['full_name'] as String?)?.trim() ?? '';
      }

      final provider =
          serviceRow['provider_profiles'] as Map<String, dynamic>? ?? const {};
      final providerOwner = (provider['owner_name'] as String?)?.trim() ?? '';
      final providerBusiness =
          (provider['business_name'] as String?)?.trim() ?? '';

      final providerName = providerOwner.isNotEmpty
          ? providerOwner
          : (providerBusiness.isNotEmpty
              ? providerBusiness
              : providerProfileName);

      final regular = (serviceRow['regular_price'] as num?)?.toDouble();
      final offer = (serviceRow['offer_price'] as num?)?.toDouble();
      final hasDiscount = regular != null &&
          offer != null &&
          regular > 0 &&
          offer > 0 &&
          offer < regular;
      final discountPct =
          hasDiscount ? (((regular - offer) / regular) * 100).round() : null;

      final reviewRatings = reviews
          .map((row) => (row['rating'] as num?)?.toDouble())
          .whereType<double>()
          .toList();
      final serviceRating = reviewRatings.isEmpty
          ? null
          : (reviewRatings.reduce((a, b) => a + b) / reviewRatings.length);

      final mappedReviews = reviews.map((row) {
        final customerId = row['customer_id'] as String?;
        final rating = (row['rating'] as num?)?.toDouble();
        final comment = (row['comment'] as String?)?.trim() ?? '';
        final createdAt = row['created_at'] as String?;

        return <String, dynamic>{
          'name':
              customerId == null ? '' : (customerNameById[customerId] ?? ''),
          'rating': rating,
          'comment': comment,
          'createdAt': createdAt,
        };
      }).toList();

      final categoryMap =
          serviceRow['service_categories'] as Map<String, dynamic>?;
      final categoryName = (categoryMap?['name'] as String?)?.trim() ?? '';

      // Check if service is favorited by current user
      bool isFavorite = false;
      final currentUserId = client.auth.currentSession?.user.id;
      if (currentUserId != null && currentUserId.isNotEmpty) {
        final favoriteCheck = await client
            .from('favorites')
            .select('id')
            .eq('customer_id', currentUserId)
            .eq('service_id', serviceId)
            .maybeSingle();
        isFavorite = favoriteCheck != null;
      }

      final resolved = <String, dynamic>{
        'id': serviceRow['id'],
        'providerId': providerId ?? '',
        'name': (serviceRow['name'] as String?)?.trim() ?? '',
        'category': categoryName,
        'description': (serviceRow['description'] as String?)?.trim() ?? '',
        'variations': (serviceRow['variations'] as String?)?.trim() ?? '',
        'faqs': (serviceRow['faqs'] as String?)?.trim() ?? '',
        'durationText': (serviceRow['duration_text'] as String?)?.trim() ?? '',
        'price': hasDiscount ? offer.toInt() : regular?.toInt(),
        'originalPrice': hasDiscount ? regular.toInt() : null,
        'discount': hasDiscount ? '$discountPct% OFF' : '',
        'rating': serviceRating,
        'reviewCount': mappedReviews.length,
        'providerName': providerName,
        'image':
            image.isNotEmpty ? image : (_resolvedServiceData['image'] ?? ''),
      };

      final providerResolved = <String, dynamic>{
        'name': providerName,
        'rating': (provider['rating_avg'] as num?)?.toDouble(),
        'reviewCount': (provider['review_count'] as num?)?.toInt(),
      };

      if (!mounted) return;
      setState(() {
        _resolvedServiceData = {
          ..._resolvedServiceData,
          ...resolved,
        };
        _providerData = providerResolved;
        _reviews = mappedReviews;
        _isFavorite = isFavorite;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentSession?.user.id;
    final serviceId = (_displayData['id'] as String?)?.trim();

    if (currentUserId == null ||
        currentUserId.isEmpty ||
        serviceId == null ||
        serviceId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to add to favorites')),
      );
      return;
    }

    try {
      if (_isFavorite) {
        // Remove from favorites
        await client
            .from('favorites')
            .delete()
            .eq('customer_id', currentUserId)
            .eq('service_id', serviceId);
      } else {
        // Add to favorites
        await client.from('favorites').insert({
          'customer_id': currentUserId,
          'service_id': serviceId,
        });
      }

      if (!mounted) return;
      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseImage = (_displayData['image'] as String?)?.trim() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSlider(baseImage),
                  _buildServiceBasicInfo(),
                  _buildTabSelector(),
                  const SizedBox(height: 16),
                  if (_selectedTabIndex == 0) _buildOverviewSection(),
                  if (_selectedTabIndex == 1) _buildVariationSection(),
                  if (_selectedTabIndex == 2) _buildReviewSection(),
                  if (_selectedTabIndex == 3) _buildFAQSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.isProviderPreview ? 'Service Preview' : 'Service Details',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        if (!widget.isProviderPreview) ...[
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            width: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5FF),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: const Color(0xFF6950F4),
                size: 20,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            width: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF5E5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.reply_rounded,
                  color: Color(0xFFFF9800), size: 20),
              onPressed: () {},
            ),
          ),
        ] else ...[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(right: 16),
            child: const Text(
              'PREVIEW',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF6950F4),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          )
        ]
      ],
    );
  }

  Widget _buildImageSlider(String imageUrl) {
    final normalized = imageUrl.trim();
    final isNetwork = normalized.startsWith('http');
    final hasImage = normalized.isNotEmpty;

    return Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF5F5F5),
      ),
      clipBehavior: Clip.antiAlias,
      child: !hasImage
          ? const Center(
              child: Icon(Icons.image_outlined, color: Colors.black26))
          : isNetwork
              ? Image.network(
                  normalized,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: Colors.black26),
                  ),
                )
              : Image.asset(
                  normalized,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: Colors.black26),
                  ),
                ),
    );
  }

  Widget _buildServiceBasicInfo() {
    final name = (_displayData['name'] as String?)?.trim() ?? '';
    final category = (_displayData['category'] as String?)?.trim() ?? '';
    final price = _currencyText(_displayData['price']);
    final originalPrice = _currencyText(_displayData['originalPrice']);
    final discount = (_displayData['discount'] as String?)?.trim() ?? '';
    final duration = (_displayData['durationText'] as String?)?.trim() ?? '';

    final ratingValue = (_displayData['rating'] as num?)?.toDouble();
    final ratingText =
        ratingValue == null ? '' : ratingValue.toStringAsFixed(1);
    final reviewCount = (_displayData['reviewCount'] as num?)?.toInt();
    final reviewText = reviewCount == null ? '' : '($reviewCount Reviews)';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6950F4),
                    ),
                  ),
                  if (originalPrice.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      originalPrice,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black38,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              if (discount.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    discount,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                duration.isEmpty ? '' : 'Duration: $duration',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    ratingText,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (reviewText.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      reviewText,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEDE9FF) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFFEDE9FF) : Colors.black12,
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF6950F4) : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewSection() {
    final description = (_displayData['description'] as String?)?.trim() ?? '';
    final providerName = (_providerData['name'] as String?)?.trim() ?? '';
    final providerRating = (_providerData['rating'] as num?)?.toDouble();
    final providerRatingText =
        providerRating == null ? '' : providerRating.toStringAsFixed(1);
    final providerReviewCount = (_providerData['reviewCount'] as num?)?.toInt();
    final providerReviewText =
        providerReviewCount == null ? '' : '($providerReviewCount Reviews)';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Service Provider',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x0A000000)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F4FD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: Color(0xFF6950F4)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            providerRatingText,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          if (providerReviewText.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              providerReviewText,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF6950F4)),
                  onPressed: () {
                    final providerName = ((_providerData['name'] as String?)
                                ?.trim() ??
                            (_displayData['providerName'] as String?)?.trim() ??
                            '')
                        .trim();
                    if (providerName.isEmpty) {
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatDetailScreen(providerName: providerName),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariationSection() {
    final variations = (_displayData['variations'] as String?)?.trim() ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Variations',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            variations,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black54,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = (_displayData['faqs'] as String?)?.trim() ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            faqs,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black54,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Reviews',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._reviews.asMap().entries.map((entry) {
            final index = entry.key;
            final review = entry.value;
            final name = (review['name'] as String?)?.trim() ?? '';
            final rating = (review['rating'] as num?)?.toDouble();
            final comment = (review['comment'] as String?)?.trim() ?? '';
            final createdAt = (review['createdAt'] as String?)?.trim() ?? '';
            return Column(
              children: [
                _buildReviewCard(
                  name: name,
                  time: _formatReviewTime(createdAt),
                  rating: rating == null ? '' : rating.toStringAsFixed(1),
                  text: comment,
                ),
                if (index != _reviews.length - 1) const Divider(),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String name,
    required String time,
    required String rating,
    required String text,
  }) {
    final initial = name.isEmpty ? '' : name[0].toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEDE9FF),
                child: Text(
                  initial,
                  style: const TextStyle(
                      color: Color(0xFF6950F4), fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: widget.isProviderPreview
              ? () {
                  Navigator.pop(context);
                }
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BookingScheduleScreen(serviceData: _displayData),
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isProviderPreview
                ? Colors.white
                : const Color(0xFF6950F4),
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: widget.isProviderPreview
                  ? const BorderSide(color: Color(0xFF6950F4), width: 2)
                  : BorderSide.none,
            ),
            elevation: 0,
          ),
          child: Text(
            widget.isProviderPreview
                ? 'Close Preview'
                : 'Book / Schedule Service',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isProviderPreview
                  ? const Color(0xFF6950F4)
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _currencyText(dynamic value) {
    if (value == null) return '';
    return 'BDT $value';
  }

  String _formatReviewTime(String rawDate) {
    if (rawDate.isEmpty) return '';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return '';

    final diff = DateTime.now().difference(parsed);
    if (diff.inDays >= 1) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} min ago';
    }
    return 'just now';
  }
}
