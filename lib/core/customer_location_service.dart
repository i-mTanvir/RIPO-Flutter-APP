// lib\core\customer_location_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SavedCustomerLocation {
  const SavedCustomerLocation({
    required this.locationId,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
  });

  final String locationId;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
}

class CustomerLocationService {
  CustomerLocationService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static Future<SavedCustomerLocation?> getDefaultLocation() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final customerProfile = await _client
        .from('customer_profiles')
        .select('default_location_id')
        .eq('user_id', userId)
        .maybeSingle();

    String? locationId =
        (customerProfile?['default_location_id'] as String?)?.trim();

    if (locationId == null || locationId.isEmpty) {
      final fallback = await _client
          .from('locations')
          .select('id')
          .eq('user_id', userId)
          .eq('is_default', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      locationId = (fallback?['id'] as String?)?.trim();
    }

    if (locationId == null || locationId.isEmpty) return null;

    final location = await _client
        .from('locations')
        .select('id, address_line, city, latitude, longitude')
        .eq('id', locationId)
        .maybeSingle();

    if (location == null) return null;

    final lat = (location['latitude'] as num?)?.toDouble();
    final lng = (location['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    final addressLine = (location['address_line'] as String?)?.trim() ?? '';
    final city = (location['city'] as String?)?.trim() ?? '';
    final fullAddress =
        [addressLine, city].where((segment) => segment.isNotEmpty).join(', ');

    return SavedCustomerLocation(
      locationId: location['id'] as String,
      address: fullAddress.isEmpty ? addressLine : fullAddress,
      city: city,
      latitude: lat,
      longitude: lng,
    );
  }

  static Future<void> setDefaultLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final normalizedAddress = address.trim().isEmpty
        ? '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}'
        : address.trim();
    final city = _extractCity(normalizedAddress);

    await _client
        .from('locations')
        .update({'is_default': false})
        .eq('user_id', userId)
        .eq('is_default', true);

    final inserted = await _client
        .from('locations')
        .insert({
          'user_id': userId,
          'label': 'Home',
          'address_line': normalizedAddress,
          'city': city,
          'latitude': latitude,
          'longitude': longitude,
          'is_default': true,
        })
        .select('id')
        .single();

    final locationId = inserted['id'] as String;

    await _client.from('customer_profiles').upsert({
      'user_id': userId,
      'default_location_id': locationId,
    });
  }

  static String _extractCity(String address) {
    final segments = address
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (segments.isEmpty) return 'Unknown';
    if (segments.length == 1) return segments.first;
    return segments[segments.length - 2];
  }
}
