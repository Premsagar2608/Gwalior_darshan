import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesService {
  static const String key = "favorites_list";

  // Save item
  static Future<void> toggleFavorite(Map item) async {
    final pref = await SharedPreferences.getInstance();
    List<String> list = pref.getStringList(key) ?? [];

    String itemJson = json.encode(item);

    if (list.contains(itemJson)) {
      list.remove(itemJson); // remove
    } else {
      list.add(itemJson); // add
    }

    await pref.setStringList(key, list);
  }

  // Check if item is favorite
  static Future<bool> isFavorite(Map item) async {
    final pref = await SharedPreferences.getInstance();
    List<String> list = pref.getStringList(key) ?? [];

    return list.contains(json.encode(item));
  }

  // Get all favorites
  static Future<List<Map>> getFavorites() async {
    final pref = await SharedPreferences.getInstance();
    List<String> list = pref.getStringList(key) ?? [];

    return list.map((e) => json.decode(e) as Map).toList();
  }
}
