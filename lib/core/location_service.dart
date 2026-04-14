import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationLookupResult {
  const LocationLookupResult({
    required this.locationText,
    this.latitude,
    this.longitude,
    this.permissionDenied = false,
    this.locationServiceDisabled = false,
  });

  final String locationText;
  final double? latitude;
  final double? longitude;
  final bool permissionDenied;
  final bool locationServiceDisabled;
}

class LocationSearchResult {
  const LocationSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  final String displayName;
  final double latitude;
  final double longitude;
}

class LocationService {
  static const String _appUserAgent = 'ripo-student-prototype/1.0';

  static Future<LocationLookupResult> detectCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationLookupResult(
          locationText: 'Turn on location service',
          locationServiceDisabled: true,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const LocationLookupResult(
          locationText: 'Location permission denied',
          permissionDenied: true,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final addressText =
          await _reverseGeocode(position.latitude, position.longitude);

      return LocationLookupResult(
        locationText: addressText,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return const LocationLookupResult(
        locationText: 'Location unavailable',
      );
    }
  }

  static Future<String> _reverseGeocode(double lat, double lng) async {
    if (!kIsWeb) {
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = <String>[
            place.street ?? '',
            place.subLocality ?? '',
            place.locality ?? '',
            place.administrativeArea ?? '',
          ].where((p) => p.trim().isNotEmpty).toList();

          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }
      } catch (_) {
        // Fallback to OSM reverse geocoding below.
      }
    }

    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': lat.toString(),
      'lon': lng.toString(),
      'format': 'jsonv2',
      'zoom': '18',
      'addressdetails': '1',
    });

    try {
      final response = await http.get(uri, headers: _requestHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final displayName = (data['display_name'] as String?)?.trim();
        if (displayName != null && displayName.isNotEmpty) {
          return displayName;
        }
      }
    } catch (_) {
      // Swallow and return coordinates fallback.
    }

    return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }

  static Future<List<LocationSearchResult>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': trimmed,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '6',
    });

    try {
      final response = await http.get(uri, headers: _requestHeaders());
      if (response.statusCode != 200) return const [];

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => item as Map<String, dynamic>)
          .map((item) {
            final lat = double.tryParse(item['lat'] as String? ?? '');
            final lon = double.tryParse(item['lon'] as String? ?? '');
            final name = (item['display_name'] as String?)?.trim() ?? '';
            if (lat == null || lon == null || name.isEmpty) return null;
            return LocationSearchResult(
              displayName: name,
              latitude: lat,
              longitude: lon,
            );
          })
          .whereType<LocationSearchResult>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<String> addressFromLatLng(double lat, double lng) {
    return _reverseGeocode(lat, lng);
  }

  static Map<String, String> _requestHeaders() {
    if (kIsWeb) {
      return const {};
    }
    return const {'User-Agent': _appUserAgent};
  }
}
