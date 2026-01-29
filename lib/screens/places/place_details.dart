import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/services/favorite_service.dart';

class PlaceDetails extends StatefulWidget {
  final Map place;

  const PlaceDetails({super.key, required this.place});

  @override
  State<PlaceDetails> createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends State<PlaceDetails> {
  // Helper to launch maps
  void openMap(double lat, double lng) async {
    final String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(googleUrl))) {
      await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place["name"],style: const TextStyle(color: Colors.white),), // Access variables via 'widget.'
        backgroundColor: const Color(0xFF1746A2),
        foregroundColor: Colors.white,
        actions: [
          FutureBuilder<bool>(
            future: FavoritesService.isFavorite(widget.place),
            builder: (context, snapshot) {
              bool isFav = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () async {
                  await FavoritesService.toggleFavorite(widget.place);
                  // setState triggers the build method to run again,
                  // causing the FutureBuilder to re-check the favorite status.
                  setState(() {});
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "${widget.place["image"]}",
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.place["name"],
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (widget.place["timing"] != null)
              Text("⏱ Timings: ${widget.place["timing"]}", style: const TextStyle(fontSize: 16)),
            if (widget.place["ticket"] != null)
              Text("🎟 Ticket: ${widget.place["ticket"]}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text(
              widget.place["description"] ?? "No description available.",
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 25),
            if (widget.place["lat"] != null && widget.place["lng"] != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => openMap(widget.place["lat"], widget.place["lng"]),
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