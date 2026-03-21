import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/accessible_button.dart';

class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  
  const MapScreen({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    final userLocation = LatLng(latitude, longitude);
    
    return Scaffold(
      appBar: AppBar(title: const Text('User Location')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: userLocation,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.assistbridge.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation,
                      width: 50,
                      height: 50,
                      child: const Icon(Icons.location_pin, color: Colors.red, size: 50),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AccessibleButton(
              label: 'Open in Maps App',
              semanticLabel: 'Tap to open navigation in maps app',
              icon: Icons.navigation,
              onPressed: () => _openInMaps(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInMaps() async {
    // Try geo: URI first — opens Google Maps directly on Android
    final geoUri = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');
    try {
      final launched = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      if (launched) return;
    } catch (_) {}

    // Fallback to Google Maps web URL
    final webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
    await launchUrl(webUri, mode: LaunchMode.externalApplication);
  }
}
