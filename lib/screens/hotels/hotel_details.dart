import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/favorite_service.dart';

class HotelDetails extends StatefulWidget {
  final Map hotel;

  const HotelDetails({super.key, required this.hotel});

  @override
  State<HotelDetails> createState() => _HotelDetailsState();
}

class _HotelDetailsState extends State<HotelDetails> {
  void openMap(double lat, double lng) async {
    final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    return Scaffold(
      appBar: AppBar(
        title: Text(hotel["name"] ,style: const TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF1746A2),
        foregroundColor: Colors.white,
        actions: [
          FutureBuilder<bool>(
            future: FavoritesService.isFavorite(hotel),
            builder: (context, snapshot) {
              final bool isFav = snapshot.data ?? false;

              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await FavoritesService.toggleFavorite(hotel);
                  setState(() {}); // ✅ now works because StatefulWidget
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
            // HOTEL IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "${hotel["image"]}",
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // NAME
            Text(
              hotel["name"] ?? "",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // PRICE
            if (hotel["price"] != null)
              Text(
                "💰 Price: ${hotel["price"]}",
                style: const TextStyle(fontSize: 16),
              ),

            // LOCATION
            if (hotel["location"] != null)
              Text(
                "📍 Location: ${hotel["location"]}",
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 20),

            // DESCRIPTION
            Text(
              hotel["description"] ?? "No description available.",
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 25),

            // MAP BUTTON
            if (hotel["lat"] != null && hotel["lng"] != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => openMap(
                    (hotel["lat"] as num).toDouble(),
                    (hotel["lng"] as num).toDouble(),
                  ),
                  icon: const Icon(Icons.map),
                  label: const Text("Open in Google Maps"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1746A2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
