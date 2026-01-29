import 'dart:convert';
import 'package:flutter/material.dart';
import '../../widgets/place_card.dart';
import 'place_details.dart';
// NEW SERVICES
import '../../services/location_service.dart';
import '../../services/distance_service.dart';

class PlacesList extends StatefulWidget {
  const PlacesList({super.key});

  @override
  State<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends State<PlacesList> {
  List<dynamic> places = [];
  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    getLocationAndLoad();
  }

  Future<void> getLocationAndLoad() async {
    // Get user location first
    final pos = await LocationService.getCurrentLocation();
    if (pos != null) {
      userLat = pos.latitude;
      userLng = pos.longitude;
    }
    loadPlaces();
  }

  Future<void> loadPlaces() async {
    final String response = await DefaultAssetBundle.of(context)
        .loadString('lib/data/places.json');

    final data = json.decode(response);
    setState(() {
      places = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tourist destinations"),
        backgroundColor: const Color(0xFF1746A2),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Expanded(
            child: places.isEmpty
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1746A2),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];

                // CALCULATE DISTANCE
                String? distanceText;
                if (userLat != null && userLng != null) {
                  final km = DistanceService.calculateDistance(
                    userLat!,
                    userLng!,
                    place["lat"],
                    place["lng"],
                  );
                  distanceText = km.toStringAsFixed(1);
                }

                return PlaceCard(
                  name: place["name"],
                  image: place["image"],
                  distance: distanceText,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceDetails(place: place),
                      ),
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
