import 'package:shared_preferences/shared_preferences.dart';

class FavoritesHelper {
  static const String _key = 'favorite_product_ids';

  static Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_key) ?? [];
  }

  static Future<bool> isFavorite(int productId) async {
    final ids = await getFavoriteIds();

    return ids.contains(productId.toString());
  }

  static Future<void> addFavorite(int productId) async {
    final prefs = await SharedPreferences.getInstance();

    final ids = prefs.getStringList(_key) ?? [];

    final id = productId.toString();

    if (!ids.contains(id)) {
      ids.add(id);

      await prefs.setStringList(_key, ids);
    }
  }

  static Future<void> removeFavorite(int productId) async {
    final prefs = await SharedPreferences.getInstance();

    final ids = prefs.getStringList(_key) ?? [];

    ids.remove(productId.toString());

    await prefs.setStringList(_key, ids);
  }

  static Future<bool> toggleFavorite(int productId) async {
    final favorite = await isFavorite(productId);

    if (favorite) {
      await removeFavorite(productId);
      return false;
    } else {
      await addFavorite(productId);
      return true;
    }
  }
}