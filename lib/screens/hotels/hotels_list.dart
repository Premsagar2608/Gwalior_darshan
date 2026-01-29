import 'dart:convert';
import 'package:flutter/material.dart';
import '../../widgets/place_card.dart';
import 'hotel_details.dart';
// NEW
import '../../services/location_service.dart';
import '../../services/distance_service.dart';

class HotelsList extends StatefulWidget {
  const HotelsList({super.key});

  @override
  State<HotelsList> createState() => _HotelsListState();
}

class _HotelsListState extends State<HotelsList> {
  List<dynamic> hotels = [];
  double? userLat;
  double? userLng;

  @override
  void initState() {
    super.initState();
    getLocationAndLoad();
  }

  Future<void> getLocationAndLoad() async {
    final pos = await LocationService.getCurrentLocation();
    if (pos != null) {
      userLat = pos.latitude;
      userLng = pos.longitude;
    }
    loadHotels();
  }

  Future<void> loadHotels() async {
    final jsonStr = await DefaultAssetBundle.of(context)
        .loadString('lib/data/hotels.json');

    setState(() {
      hotels = json.decode(jsonStr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotels"),
        backgroundColor: const Color(0xFF1746A2),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Expanded(
            child: hotels.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: hotels.length,
              itemBuilder: (context, index) {
                final hotel = hotels[index];

                String? distanceText;
                if (userLat != null) {
                  final km = DistanceService.calculateDistance(
                    userLat!,
                    userLng!,
                    hotel["lat"],
                    hotel["lng"],
                  );
                  distanceText = km.toStringAsFixed(1);
                }

                return PlaceCard(
                  name: hotel["name"],
                  image: hotel["image"],
                  distance: distanceText,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HotelDetails(hotel: hotel),
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
