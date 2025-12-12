import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';

class ItemRepository {
  static const _storageKey = 'items_v1';

  Future<List<Item>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((e) => Item.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveItems(List<Item> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
