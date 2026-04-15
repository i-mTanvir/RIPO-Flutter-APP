// lib\core\provider_location_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SavedProviderLocation {
  const SavedProviderLocation({
    this.locationId,
    required this.address,
    this.city,
    this.latitude,
    this.longitude,
  });

  final String? locationId;
  final String address;
  final String? city;
  final double? latitude;
  final double? longitude;
}

class ProviderLocationService {
  ProviderLocationService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static Future<SavedProviderLocation?> getDefaultLocation() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final location = await _client
        .from('locations')
        .select('id, address_line, city, latitude, longitude')
        .eq('user_id', userId)
        .eq('is_default', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (location != null) {
      final addressLine = (location['address_line'] as String?)?.trim() ?? '';
      final city = (location['city'] as String?)?.trim();
      final fullAddress = [addressLine, city]
          .where((segment) => segment != null && segment.trim().isNotEmpty)
          .join(', ');

      return SavedProviderLocation(
        locationId: location['id'] as String?,
        address: fullAddress.isEmpty ? addressLine : fullAddress,
        city: city,
        latitude: (location['latitude'] as num?)?.toDouble(),
        longitude: (location['longitude'] as num?)?.toDouble(),
      );
    }

    final providerProfile = await _client
        .from('provider_profiles')
        .select('service_area_text')
        .eq('user_id', userId)
        .maybeSingle();

    final areaText =
        (providerProfile?['service_area_text'] as String?)?.trim() ?? '';
    if (areaText.isEmpty) return null;

    return SavedProviderLocation(
      address: areaText,
    );
  }

  static Future<String> setDefaultLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('You must be logged in as a provider.');
    }

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
          'label': 'Service Area',
          'address_line': normalizedAddress,
          'city': city,
          'latitude': latitude,
          'longitude': longitude,
          'is_default': true,
        })
        .select('id')
        .single();

    final locationId = inserted['id'] as String;

    await _client
        .from('provider_profiles')
        .update({'service_area_text': normalizedAddress}).eq('user_id', userId);

    return locationId;
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
