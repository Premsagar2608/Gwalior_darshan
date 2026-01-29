import 'dart:convert';
import 'package:flutter/material.dart';
import '../places/place_details.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _loading = true;
  String _query = "";

  List<dynamic> _places = [];
  List<dynamic> _hotels = [];
  List<dynamic> _food = [];

  int _tabIndex = 0; // 0=All, 1=Places, 2=Hotels, 3=Food

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _loading = true);
    try {
      final placesStr =
      await DefaultAssetBundle.of(context).loadString('lib/data/places.json');
      final hotelsStr =
      await DefaultAssetBundle.of(context).loadString('lib/data/hotels.json');
      final foodStr =
      await DefaultAssetBundle.of(context).loadString('lib/data/food.json');

      final p = json.decode(placesStr);
      final h = json.decode(hotelsStr);
      final f = json.decode(foodStr);

      if (!mounted) return;
      setState(() {
        _places = (p is List) ? p : [];
        _hotels = (h is List) ? h : [];
        _food = (f is List) ? f : [];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load search data: $e")),
      );
    }
  }

  // ---------- filtering helpers ----------
  bool _matchesPlace(Map place, String q) {
    final name = (place["name"] ?? "").toString().toLowerCase();
    final desc = (place["description"] ?? "").toString().toLowerCase();
    final story = (place["story"] ?? "").toString().toLowerCase();
    final timing = (place["timing"] ?? "").toString().toLowerCase();
    final ticket = (place["ticket"] ?? "").toString().toLowerCase();
    return name.contains(q) ||
        desc.contains(q) ||
        story.contains(q) ||
        timing.contains(q) ||
        ticket.contains(q);
  }

  bool _matchesHotel(Map hotel, String q) {
    final name = (hotel["name"] ?? "").toString().toLowerCase();
    final desc = (hotel["description"] ?? "").toString().toLowerCase();
    final loc = (hotel["location"] ?? "").toString().toLowerCase();
    final price = (hotel["price"] ?? "").toString().toLowerCase();
    final rating = (hotel["rating"] ?? "").toString().toLowerCase();
    return name.contains(q) ||
        desc.contains(q) ||
        loc.contains(q) ||
        price.contains(q) ||
        rating.contains(q);
  }

  bool _matchesFood(Map food, String q) {
    final name = (food["name"] ?? "").toString().toLowerCase();
    final desc = (food["description"] ?? "").toString().toLowerCase();
    final loc = (food["location"] ?? "").toString().toLowerCase();
    return name.contains(q) || desc.contains(q) || loc.contains(q);
  }

  List<Map<String, dynamic>> _filteredPlaces() {
    final q = _query.trim().toLowerCase();
    final list = _places.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    if (q.isEmpty) return list;
    return list.where((p) => _matchesPlace(p, q)).toList();
  }

  List<Map<String, dynamic>> _filteredHotels() {
    final q = _query.trim().toLowerCase();
    final list = _hotels.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    if (q.isEmpty) return list;
    return list.where((h) => _matchesHotel(h, q)).toList();
  }

  List<Map<String, dynamic>> _filteredFood() {
    final q = _query.trim().toLowerCase();
    final list = _food.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    if (q.isEmpty) return list;
    return list.where((f) => _matchesFood(f, q)).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final places = _filteredPlaces();
    final hotels = _filteredHotels();
    final foods = _filteredFood();

    // Build results based on tab
    final List<_SearchItem> results = () {
      final items = <_SearchItem>[];
      if (_tabIndex == 0 || _tabIndex == 1) {
        items.addAll(places.map((p) => _SearchItem(type: _Type.place, data: p)));
      }
      if (_tabIndex == 0 || _tabIndex == 2) {
        items.addAll(hotels.map((h) => _SearchItem(type: _Type.hotel, data: h)));
      }
      if (_tabIndex == 0 || _tabIndex == 3) {
        items.addAll(foods.map((f) => _SearchItem(type: _Type.food, data: f)));
      }
      return items;
    }();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: const Color(0xFF1746A2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Row(
              children: [
                _chip("All", 0),
                const SizedBox(width: 8),
                _chip("Places", 1),
                const SizedBox(width: 8),
                _chip("Hotels", 2),
                const SizedBox(width: 8),
                _chip("Food", 3),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: "Search name, location, description, price...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _query = "");
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : results.isEmpty
                ? const Center(child: Text("No results found"))
                : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = results[index];
                final data = item.data;

                final title = (data["name"] ?? "Unknown").toString();
                final image = (data["image"] ?? "").toString();
                final subtitle = _subtitleFor(item.type, data);

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: image.isNotEmpty
                          ? Image.asset(
                        image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _fallbackImage(),
                      )
                          : _fallbackImage(),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _typeBadge(item.type),
                      ],
                    ),
                    subtitle: Text(subtitle),
                    onTap: () {
                      if (item.type == _Type.place) {
                        // Only Places go to PlaceDetails (safe)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaceDetails(place: data),
                          ),
                        );
                      } else {
                        // Hotels/Food: show quick info (no extra screens needed)
                        _showInfoDialog(context, item.type, data);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, int index) {
    final selected = _tabIndex == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF1746A2) : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  String _subtitleFor(_Type type, Map<String, dynamic> data) {
    if (type == _Type.place) {
      final timing = (data["timing"] ?? "").toString();
      final ticket = (data["ticket"] ?? "").toString();
      final desc = (data["description"] ?? "").toString();
      if (timing.isNotEmpty || ticket.isNotEmpty) {
        return [timing, ticket].where((e) => e.trim().isNotEmpty).join(" • ");
      }
      return desc.isNotEmpty ? desc : "Tap to view details";
    }

    if (type == _Type.hotel) {
      final price = (data["price"] ?? "").toString();
      final rating = (data["rating"] ?? "").toString();
      final loc = (data["location"] ?? "").toString();
      return [price, "⭐ $rating", loc]
          .where((e) => e.trim().isNotEmpty)
          .join(" • ");
    }

    // food
    final loc = (data["location"] ?? "").toString();
    final desc = (data["description"] ?? "").toString();
    return [loc, desc].where((e) => e.trim().isNotEmpty).join(" • ");
  }

  Widget _typeBadge(_Type type) {
    final text = type == _Type.place
        ? "Place"
        : type == _Type.hotel
        ? "Hotel"
        : "Food";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, _Type type, Map<String, dynamic> data) {
    final title = (data["name"] ?? "").toString();
    final desc = (data["description"] ?? "").toString();
    final loc = (data["location"] ?? "").toString();
    final extra = type == _Type.hotel
        ? "Price: ${(data["price"] ?? "").toString()}\nRating: ${(data["rating"] ?? "").toString()}"
        : "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title.isEmpty ? "Details" : title),
        content: Text(
          [
            if (loc.isNotEmpty) "Location: $loc",
            if (extra.isNotEmpty) extra,
            if (desc.isNotEmpty) "\n$desc",
          ].join("\n"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
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

enum _Type { place, hotel, food }

class _SearchItem {
  final _Type type;
  final Map<String, dynamic> data;
  _SearchItem({required this.type, required this.data});
}
