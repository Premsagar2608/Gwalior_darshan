import 'dart:convert';
import 'package:flutter/material.dart';
import '../../widgets/place_card.dart';
import 'food_details.dart';
// NEW
import '../../services/location_service.dart';
import '../../services/distance_service.dart';

class FoodList extends StatefulWidget {
  const FoodList({super.key});

  @override
  State<FoodList> createState() => _FoodListState();
}

class _FoodListState extends State<FoodList> {
  List<dynamic> foods = [];
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
    loadFood();
  }

  Future<void> loadFood() async {
    final jsonStr = await DefaultAssetBundle.of(context)
        .loadString('lib/data/food.json');

    setState(() {
      foods = json.decode(jsonStr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Foods"),
        backgroundColor: const Color(0xFF1746A2),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Expanded(
            child: foods.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final food = foods[index];

                String? distanceText;
                if (userLat != null) {
                  final km = DistanceService.calculateDistance(
                    userLat!,
                    userLng!,
                    food["lat"],
                    food["lng"],
                  );
                  distanceText = km.toStringAsFixed(1);
                }

                return PlaceCard(
                  name: food["name"],
                  image: food["image"],
                  distance: distanceText,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FoodDetails(food: food),
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
