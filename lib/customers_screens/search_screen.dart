import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/service_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'Recommended'; // Options: Recommended, Price (Low to High), Price (High to Low), Rating (High to Low)

  void _popScreen<T extends Object?>([T? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(result);
    });
  }

  void _pushToDetails(Map<String, dynamic> serviceData) {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ServiceDetailsScreen(serviceData: serviceData),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.isNotEmpty) {
      _searchQuery = widget.initialQuery;
      _searchController.text = widget.initialQuery;
    }
  }

  // Rich mock data representing all services
  final List<Map<String, dynamic>> _allServices = [
    {
      'name': 'Home Sanitization',
      'discount': '40% OFF',
      'price': 1200,
      'originalPrice': '2,000',
      'rating': 4.5,
      'image': 'lib/media/clean_house_offer.png',
      'isFavorite': false,
    },
    {
      'name': 'AC Servicing',
      'discount': '30% OFF',
      'price': 1500,
      'originalPrice': '2,100',
      'rating': 4.8,
      'image': 'lib/media/AC_servicing.png',
      'isFavorite': true,
    },
    {
      'name': 'Electronics Service',
      'discount': '50% OFF',
      'price': 800,
      'originalPrice': '1,600',
      'rating': 4.2,
      'image': 'lib/media/electronics_servicing.png',
      'isFavorite': false,
    },
    {
      'name': 'Fan & Light Service',
      'discount': '10% OFF',
      'price': 300,
      'originalPrice': '350',
      'rating': 4.6,
      'image': 'lib/media/fan_light_servicing.png',
      'isFavorite': false,
    },
    {
      'name': 'House Cleaning',
      'discount': '20% OFF',
      'price': 2000,
      'originalPrice': '2,500',
      'rating': 4.9,
      'image': 'lib/media/clean_house_offer.png',
      'isFavorite': false,
    },
    {
      'name': 'Laundry Service',
      'discount': '15% OFF',
      'price': 500,
      'originalPrice': '700',
      'rating': 4.1,
      'image': 'lib/media/loundry_washing_offer.png',
      'isFavorite': false,
    },
    {
      'name': 'TV Repair',
      'discount': '25% OFF',
      'price': 1800,
      'originalPrice': '2,400',
      'rating': 4.4,
      'image': 'lib/media/TV_servicing.png',
      'isFavorite': false,
    },
    {
      'name': 'Painting',
      'discount': '35% OFF',
      'price': 3500,
      'originalPrice': '4,500',
      'rating': 4.7,
      'image': 'lib/media/paint_servicing.png',
      'isFavorite': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredAndSortedServices {
    // Filter
    List<Map<String, dynamic>> result = _allServices.where((s) {
      if (_searchQuery.trim().isEmpty) return true;

      final serviceName = (s['name'] as String).toLowerCase();
      final queryLower = _searchQuery.toLowerCase().trim();

      // Exact match check first
      if (serviceName.contains(queryLower)) return true;

      // Fuzzy "Like" word match
      final searchWords = queryLower.split(' ');
      for (var word in searchWords) {
        // Match if any meaningful word exists 
        // e.g. clicking "AC Repair" will correctly find "AC Servicing" because "ac" matches
        if (word.length > 1 && serviceName.contains(word)) {
          return true;
        }
      }
      return false;
    }).toList();

    // Sort
    if (_sortBy == 'Price (Low to High)') {
      result.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    } else if (_sortBy == 'Price (High to Low)') {
      result.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    } else if (_sortBy == 'Rating (High to Low)') {
      result.sort(
          (a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    }

    return result;
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Sort By',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Divider(),
              _buildSortOption('Recommended'),
              _buildSortOption('Price (Low to High)'),
              _buildSortOption('Price (High to Low)'),
              _buildSortOption('Rating (High to Low)'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String value) {
    bool isSelected = _sortBy == value;
    return ListTile(
      title: Text(
        value,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? const Color(0xFF6950F4) : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6950F4))
          : null,
      onTap: () {
        setState(() => _sortBy = value);
        _popScreen();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 22),
          onPressed: () => _popScreen(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0x0A000000)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, color: Colors.black87, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                autofocus: !kIsWeb,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  isDense: true,
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.black45,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(width: 1, height: 20, color: Colors.black12),
            GestureDetector(
              onTap: _showFilterOptions,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFD6D0FA),
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(21)),
                ),
                alignment: Alignment.center,
                child: Row(
                  children: const [
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.filter_list_rounded,
                        size: 14, color: Colors.black87),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _filteredAndSortedServices;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              'No services found.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(results[index]);
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> s) {
    return GestureDetector(
      onTap: () => _pushToDetails(s),
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
          // Image + Badge
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: const Color(0xFFF5F5F5),
                  child: Image.asset(
                    s['image'],
                    fit: BoxFit.cover, 
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
                      s['discount'],
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
          // Details
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s['name'],
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
                            '৳ ${s['price']}',
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
                            s['isFavorite'] = !s['isFavorite'];
                          });
                        },
                          child: Icon(
                            s['isFavorite']
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
