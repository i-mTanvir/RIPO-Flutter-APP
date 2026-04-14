import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ProviderDistanceMapBottomSheet extends StatefulWidget {
  const ProviderDistanceMapBottomSheet({
    super.key,
    required this.providerLat,
    required this.providerLng,
    required this.customerLat,
    required this.customerLng,
    required this.customerAddress,
  });

  final double providerLat;
  final double providerLng;
  final double customerLat;
  final double customerLng;
  final String customerAddress;

  static Future<void> show(
    BuildContext context, {
    required double providerLat,
    required double providerLng,
    required double customerLat,
    required double customerLng,
    required String customerAddress,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProviderDistanceMapBottomSheet(
        providerLat: providerLat,
        providerLng: providerLng,
        customerLat: customerLat,
        customerLng: customerLng,
        customerAddress: customerAddress,
      ),
    );
  }

  @override
  State<ProviderDistanceMapBottomSheet> createState() =>
      _ProviderDistanceMapBottomSheetState();
}

class _ProviderDistanceMapBottomSheetState
    extends State<ProviderDistanceMapBottomSheet> {
  _TravelMode _travelMode = _TravelMode.vehicle;
  late final LatLng _providerPoint;
  late final LatLng _customerPoint;

  bool _isLoadingRoute = true;
  bool _usingFallbackLine = false;
  double _displayDistanceKm = 0;
  List<LatLng> _routePoints = const [];

  @override
  void initState() {
    super.initState();
    _providerPoint = LatLng(widget.providerLat, widget.providerLng);
    _customerPoint = LatLng(widget.customerLat, widget.customerLng);
    _displayDistanceKm = const Distance()
        .as(LengthUnit.Kilometer, _providerPoint, _customerPoint);
    _routePoints = [_providerPoint, _customerPoint];
    _loadRoadRoute();
  }

  Future<void> _loadRoadRoute() async {
    setState(() {
      _isLoadingRoute = true;
      _usingFallbackLine = false;
    });

    final profile = _travelMode == _TravelMode.vehicle ? 'driving' : 'foot';
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/$profile/'
      '${widget.providerLng},${widget.providerLat};'
      '${widget.customerLng},${widget.customerLat}'
      '?overview=full&geometries=geojson&steps=false',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        if (!mounted) return;
        setState(() {
          _isLoadingRoute = false;
          _usingFallbackLine = true;
        });
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>? ?? const [];
      if (routes.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoadingRoute = false;
          _usingFallbackLine = true;
        });
        return;
      }

      final firstRoute = routes.first as Map<String, dynamic>;
      final distanceMeters = (firstRoute['distance'] as num?)?.toDouble();
      final geometry = firstRoute['geometry'] as Map<String, dynamic>?;
      final coords = geometry?['coordinates'] as List<dynamic>? ?? const [];

      final points = coords
          .whereType<List<dynamic>>()
          .map((coord) {
            if (coord.length < 2) return null;
            final lon = (coord[0] as num?)?.toDouble();
            final lat = (coord[1] as num?)?.toDouble();
            if (lat == null || lon == null) return null;
            return LatLng(lat, lon);
          })
          .whereType<LatLng>()
          .toList();

      if (!mounted) return;
      setState(() {
        _isLoadingRoute = false;
        _usingFallbackLine = points.isEmpty;
        _routePoints =
            points.isEmpty ? [_providerPoint, _customerPoint] : points;
        if (distanceMeters != null && distanceMeters > 0) {
          _displayDistanceKm = distanceMeters / 1000;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingRoute = false;
        _usingFallbackLine = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      (widget.providerLat + widget.customerLat) / 2,
      (widget.providerLng + widget.customerLng) / 2,
    );

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.78,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Distance to Customer',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_displayDistanceKm.toStringAsFixed(2)} km',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6950F4),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildModeChip(
                mode: _TravelMode.vehicle,
                icon: Icons.directions_car_rounded,
                label: 'Vehicle',
              ),
              const SizedBox(width: 10),
              _buildModeChip(
                mode: _TravelMode.walking,
                icon: Icons.directions_walk_rounded,
                label: 'Walking',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ripo.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 4,
                          color: const Color(0xFF6950F4),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _providerPoint,
                          width: 44,
                          height: 44,
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Color(0xFF43A047),
                            size: 30,
                          ),
                        ),
                        Marker(
                          point: _customerPoint,
                          width: 44,
                          height: 44,
                          child: const Icon(
                            Icons.location_pin,
                            color: Color(0xFFFF5252),
                            size: 34,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoadingRoute)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_usingFallbackLine)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Road route unavailable, showing straight line.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.customerAddress,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required _TravelMode mode,
    required IconData icon,
    required String label,
  }) {
    final selected = _travelMode == mode;
    return InkWell(
      onTap: _isLoadingRoute || selected
          ? null
          : () {
              setState(() => _travelMode = mode);
              _loadRoadRoute();
            },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEDE9FF) : const Color(0xFFF1F1F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF6950F4) : const Color(0xFFDADAE2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? const Color(0xFF6950F4) : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? const Color(0xFF6950F4) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _TravelMode { vehicle, walking }
