import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gwaliorCenter = LatLng(26.2183, 78.1828); // Center of Gwalior

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gwalior Map"),
        backgroundColor: const Color(0xFF1746A2),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: gwaliorCenter,
          initialZoom: 13,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          // --- MAP LAYER (OpenStreetMap) ---
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.gwalior_darshan',
          ),

          // --- MARKERS ---
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(26.2313, 78.1694),
                child: Tooltip(
                  message: "Gwalior Fort",
                  child: Icon(Icons.location_on, color: Colors.red, size: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
