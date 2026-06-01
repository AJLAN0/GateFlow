import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'gateflow_colors.dart';

/// A picked point on the map (device GPS or tap-to-select).
class GateFlowSelectedLocation {
  const GateFlowSelectedLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final double latitude;
  final double longitude;
  final String label;

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}

/// Easy location picking — no Google Maps API key required.
class GateFlowLocationPicker {
  GateFlowLocationPicker._();

  /// Default map center (Buraydah / Qassim — matches form hints).
  static const LatLng defaultCenter = LatLng(26.3592, 43.9818);

  static Future<bool> _ensurePermission(BuildContext context) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Turn on location services in device settings.'),
          ),
        );
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to detect GPS.'),
          ),
        );
      }
      return false;
    }
    return true;
  }

  static Future<String> _labelFor(double lat, double lng) async {
    try {
      final places = await placemarkFromCoordinates(lat, lng);
      if (places.isEmpty) {
        return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      }
      final p = places.first;
      final parts = [
        if ((p.subLocality ?? '').isNotEmpty) p.subLocality,
        if ((p.locality ?? '').isNotEmpty) p.locality,
        if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea,
      ].whereType<String>().toList();
      if (parts.isEmpty) {
        return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      }
      return parts.join(' · ');
    } catch (_) {
      return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    }
  }

  /// Uses the device GPS (for the detect / my-location button).
  static Future<GateFlowSelectedLocation?> currentLocation(
    BuildContext context,
  ) async {
    if (!await _ensurePermission(context)) return null;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final label = await _labelFor(pos.latitude, pos.longitude);
      return GateFlowSelectedLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        label: label,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get GPS: $e')),
        );
      }
      return null;
    }
  }

  /// Opens a free OpenStreetMap picker — tap anywhere to drop a pin.
  static Future<GateFlowSelectedLocation?> pickOnMap(
    BuildContext context, {
    GateFlowSelectedLocation? initial,
  }) {
    final start = initial != null
        ? LatLng(initial.latitude, initial.longitude)
        : defaultCenter;

    return showModalBottomSheet<GateFlowSelectedLocation>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MapPickerSheet(initial: start),
    );
  }
}

class _MapPickerSheet extends StatefulWidget {
  const _MapPickerSheet({required this.initial});

  final LatLng initial;

  @override
  State<_MapPickerSheet> createState() => _MapPickerSheetState();
}

class _MapPickerSheetState extends State<_MapPickerSheet> {
  late LatLng _pin;
  final _mapController = MapController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _pin = widget.initial;
  }

  Future<void> _useMyLocation() async {
    setState(() => _busy = true);
    final loc = await GateFlowLocationPicker.currentLocation(context);
    if (!mounted) return;
    setState(() => _busy = false);
    if (loc == null) return;
    final latLng = LatLng(loc.latitude, loc.longitude);
    setState(() => _pin = latLng);
    _mapController.move(latLng, 15);
  }

  Future<void> _confirm() async {
    setState(() => _busy = true);
    final label = await GateFlowLocationPicker._labelFor(_pin.latitude, _pin.longitude);
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).pop(
      GateFlowSelectedLocation(
        latitude: _pin.latitude,
        longitude: _pin.longitude,
        label: label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.78;
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tap the map to set location',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: GateFlowColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _busy ? null : _useMyLocation,
                  icon: const Icon(Icons.my_location_rounded),
                  tooltip: 'Use my location',
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _pin,
                    initialZoom: 14,
                    onTap: (_, point) => setState(() => _pin = point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.gateflow.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _pin,
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.location_pin,
                            size: 44,
                            color: GateFlowColors.brandPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _busy ? null : _confirm,
              style: FilledButton.styleFrom(
                backgroundColor: GateFlowColors.brandAccent,
                foregroundColor: GateFlowColors.textPrimary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirm location'),
            ),
          ),
        ],
      ),
    );
  }
}
