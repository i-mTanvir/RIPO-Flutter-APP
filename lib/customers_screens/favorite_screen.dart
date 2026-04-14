import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Fetch favorites for the current user with service and provider details
      final response = await client.from('favorites').select('''
            id,
            service_id,
            services(
              id,
              name,
              regular_price,
              offer_price,
              provider_id,
              provider_profiles(
                business_name,
                owner_name
              )
            )
          ''').eq('customer_id', userId);

      if (!mounted) return;

      final List<Map<String, dynamic>> favoritesList = [];
      for (var item in response) {
        final service = item['services'] as Map<String, dynamic>?;
        if (service != null) {
          final provider =
              service['provider_profiles'] as Map<String, dynamic>?;
          favoritesList.add({
            'id': item['id'],
            'service_id': service['id'],
            'name': service['name'] ?? 'Unknown Service',
            'provider': provider?['business_name'] ??
                provider?['owner_name'] ??
                'Unknown Provider',
            'price': service['offer_price'] ?? service['regular_price'] ?? '0',
            'image':
                'lib/media/AC_servicing.png', // Default image; should come from service_media table
          });
        }
      }

      if (!mounted) return;
      setState(() {
        _favorites = favoritesList;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading favorites: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _removeFavorite(int index, String name) async {
    final favoriteId = _favorites[index]['id'];

    try {
      // Remove from database
      await Supabase.instance.client
          .from('favorites')
          .delete()
          .eq('id', favoriteId);

      // Remove from local list
      if (!mounted) return;
      setState(() {
        _favorites.removeAt(index);
      });

      // Smooth responsive feedback to the user on deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name removed from favorites.'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () {
              // Could implement undo by re-adding to favorites
            },
          ),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing from favorites: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text(
          'Favorite Services',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(
                  child: Text(
                    'No favorites yet.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.black45,
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = _favorites[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Image Thumbnail Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 65,
                              height: 65,
                              color: const Color(0xFFF0F0F0),
                              child: Image.asset(
                                favorite['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Safely fallback if image asset is not natively available locally
                                  return const Center(
                                    child: Icon(Icons.image_rounded,
                                        color: Colors.black26),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Text Identifiers Block
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  favorite['name'],
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  favorite['provider'],
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black45,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // The Filled Heart Action Button
                          IconButton(
                            onPressed: () =>
                                _removeFavorite(index, favorite['name']),
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.redAccent,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
