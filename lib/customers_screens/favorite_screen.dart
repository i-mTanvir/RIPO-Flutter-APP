import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // Simulating mock data with standard generic placeholder image logic where necessary
  final List<Map<String, dynamic>> _favorites = [
    {
      'id': '1',
      'name': 'AC Servicing Core',
      'provider': 'Tanvir Mahmud',
      'image': 'lib/media/AC_servicing.png', 
    },
    {
      'id': '2',
      'name': 'Complete Home Cleaning',
      'provider': 'CleanMaster BD',
      'image': 'lib/media/clean_house_offer.png',
    },
    {
      'id': '3',
      'name': 'Basic Plumbing Fixes',
      'provider': 'Shaidul Islam',
      'image': 'lib/media/plumbing.png', 
    },
  ];

  void _removeFavorite(int index, String name) {
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
            // Advanced but simulated structural behavior
          },
        ),
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
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
      body: _favorites.isEmpty 
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                                child: Icon(Icons.image_rounded, color: Colors.black26),
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
                        onPressed: () => _removeFavorite(index, favorite['name']),
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
