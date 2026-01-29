import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/favorite_service.dart';

class FoodDetails extends StatefulWidget {
  final Map food;

  const FoodDetails({super.key, required this.food});

  @override
  State<FoodDetails> createState() => _FoodDetailsState();
}

class _FoodDetailsState extends State<FoodDetails> {
  void openMap(double lat, double lng) async {
    final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    final double? lat = _toDouble(food["lat"]);
    final double? lng = _toDouble(food["lng"]);

    return Scaffold(
      appBar: AppBar(
        title: Text(food["name"] ,style: const TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF1746A2),
        foregroundColor: Colors.white,
        actions: [
          FutureBuilder<bool>(
            future: FavoritesService.isFavorite(food),
            builder: (context, snapshot) {
              final bool isFav = snapshot.data ?? false;

              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await FavoritesService.toggleFavorite(food);
                  setState(() {}); // ✅ now works (StatefulWidget)
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "${food["image"]}",
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // NAME
            Text(
              food["name"],
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // LOCATION
            if (food["location"] != null)
              Text(
                "📍 Famous at: ${food["location"]}",
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 15),

            // DESCRIPTION
            Text(
              food["description"] ?? "No description available.",
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 25),

            // MAP BUTTON
            if (lat != null && lng != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => openMap(lat, lng),
                  icon: const Icon(Icons.map),
                  label: const Text("Open in Google Maps"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF1746A2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
