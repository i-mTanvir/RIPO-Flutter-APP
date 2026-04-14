import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ripo/core/location_service.dart';

class PickedLocation {
  const PickedLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;
}

enum _MapViewMode { traffic, satellite, terrain }

class LocationPickerBottomSheet extends StatefulWidget {
  const LocationPickerBottomSheet({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  static Future<PickedLocation?> show(
    BuildContext context, {
    double? initialLatitude,
    double? initialLongitude,
    String? initialAddress,
  }) {
    return showModalBottomSheet<PickedLocation>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LocationPickerBottomSheet(
        initialLatitude: initialLatitude,
        initialLongitude: initialLongitude,
        initialAddress: initialAddress,
      ),
    );
  }

  @override
  State<LocationPickerBottomSheet> createState() =>
      _LocationPickerBottomSheetState();
}

class _LocationPickerBottomSheetState extends State<LocationPickerBottomSheet> {
  static const LatLng _fallbackLatLng = LatLng(23.8103, 90.4125);

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late LatLng _selectedLatLng;
  String _selectedAddress = 'Detecting address...';
  bool _isLoadingAddress = false;
  bool _isSearching = false;
  bool _isResolvingCurrent = false;
  _MapViewMode _mapViewMode = _MapViewMode.traffic;
  Timer? _reverseDebounce;

  @override
  void initState() {
    super.initState();
    _selectedLatLng = LatLng(
      widget.initialLatitude ?? _fallbackLatLng.latitude,
      widget.initialLongitude ?? _fallbackLatLng.longitude,
    );
    _selectedAddress = widget.initialAddress?.trim().isNotEmpty == true
        ? widget.initialAddress!.trim()
        : '${_selectedLatLng.latitude.toStringAsFixed(5)}, '
            '${_selectedLatLng.longitude.toStringAsFixed(5)}';

    _resolveAddress(_selectedLatLng);
  }

  @override
  void dispose() {
    _reverseDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String get _tileTemplate {
    switch (_mapViewMode) {
      case _MapViewMode.traffic:
        return 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png';
      case _MapViewMode.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/'
            'World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case _MapViewMode.terrain:
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
    }
  }

  List<String> get _subdomains {
    switch (_mapViewMode) {
      case _MapViewMode.satellite:
        return const [];
      case _MapViewMode.traffic:
      case _MapViewMode.terrain:
        return const ['a', 'b', 'c'];
    }
  }

  Future<void> _resolveAddress(LatLng latLng) async {
    setState(() => _isLoadingAddress = true);
    final address = await LocationService.addressFromLatLng(
        latLng.latitude, latLng.longitude);
    if (!mounted) return;
    setState(() {
      _selectedAddress = address;
      _isLoadingAddress = false;
    });
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    final center = camera.center;
    _selectedLatLng = center;
    _reverseDebounce?.cancel();
    _reverseDebounce = Timer(const Duration(milliseconds: 600), () {
      _resolveAddress(center);
    });
    setState(() {});
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _isResolvingCurrent = true);
    final result = await LocationService.detectCurrentLocation();
    if (!mounted) return;

    if (result.latitude != null && result.longitude != null) {
      final current = LatLng(result.latitude!, result.longitude!);
      _mapController.move(current, 16);
      setState(() {
        _selectedLatLng = current;
        _selectedAddress = result.locationText;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.locationText)),
      );
    }

    if (mounted) {
      setState(() => _isResolvingCurrent = false);
    }
  }

  Future<void> _searchAndMove() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    final results = await LocationService.searchPlaces(query);
    if (!mounted) return;
    setState(() => _isSearching = false);

    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location found for this search.')),
      );
      return;
    }

    final picked = await showModalBottomSheet<LocationSearchResult>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final item = results[i];
            return ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(
                item.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.of(context).pop(item),
            );
          },
        ),
      ),
    );

    if (!mounted || picked == null) return;
    final target = LatLng(picked.latitude, picked.longitude);
    _mapController.move(target, 16);
    setState(() {
      _selectedLatLng = target;
      _selectedAddress = picked.displayName;
    });
  }

  void _setLocationAndClose() {
    Navigator.of(context).pop(
      PickedLocation(
        latitude: _selectedLatLng.latitude,
        longitude: _selectedLatLng.longitude,
        address: _selectedAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final sheetHeight = media.size.height * 0.88;

    return SizedBox(
      height: sheetHeight,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchAndMove(),
                    decoration: InputDecoration(
                      hintText: 'Search in map',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _searchAndMove,
                    child: _isSearching
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Search'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLatLng,
                    initialZoom: 15,
                    onPositionChanged: _onMapPositionChanged,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _tileTemplate,
                      subdomains: _subdomains,
                      userAgentPackageName: 'com.ripo.app',
                    ),
                  ],
                ),
                IgnorePointer(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.location_pin,
                          size: 44,
                          color: Color(0xFF6950F4),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<_MapViewMode>(
                    onSelected: (mode) => setState(() => _mapViewMode = mode),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _MapViewMode.traffic,
                        child: Text('Traffic (Default)'),
                      ),
                      PopupMenuItem(
                        value: _MapViewMode.satellite,
                        child: Text('Satellite'),
                      ),
                      PopupMenuItem(
                        value: _MapViewMode.terrain,
                        child: Text('Terrain'),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.layers_outlined, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 6,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _selectedAddress,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (_isLoadingAddress)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _isResolvingCurrent ? null : _goToCurrentLocation,
                        icon: _isResolvingCurrent
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location_rounded),
                        label: const Text('Current Location'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _setLocationAndClose,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6950F4),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Set My Location'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
