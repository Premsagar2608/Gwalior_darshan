import 'package:flutter/material.dart';
import '../../services/favorite_service.dart'; // <- this is your uploaded file (FavoritesService)

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _loading = true;
  List<Map> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);

    try {
      final data = await FavoritesService.getFavorites();
      if (!mounted) return;

      setState(() {
        _favorites = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load favorites: $e")),
      );
    }
  }

  Future<void> _removeFavorite(Map place) async {
    try {
      await FavoritesService.toggleFavorite(place); // removes if exists
      await _loadFavorites(); // refresh UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favourite Places"),
        backgroundColor: const Color(0xFF1746A2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
          ? const Center(
        child: Text(
          "No favorite places yet ❤️",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _favorites.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final place = _favorites[index];

          final String name =
          (place["name"] ?? "Unknown Place").toString();
          final String location =
          (place["location"] ?? "Gwalior").toString();
          final String? imagePath = place["image"]?.toString();

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (imagePath != null && imagePath.isNotEmpty)
                    ? Image.asset(
                  imagePath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _fallbackImage(),
                )
                    : _fallbackImage(),
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(location),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeFavorite(place),
              ),
              onTap: () {
                // ✅ No PlaceDetails dependency here (prevents compile errors)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Selected: $name")),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported),
    );
  }
}
