import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/navigation_history.dart';

class NavigationHistoryService {
  static const int _maximumEntries = 100;

  static String _storageKey(String username) =>
      'navigation_history_${username.trim().toLowerCase()}';

  static Future<List<NavigationHistoryEntry>> load(String username) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedEntries =
        preferences.getStringList(_storageKey(username)) ?? const [];
    final entries = <NavigationHistoryEntry>[];

    for (final encodedEntry in encodedEntries) {
      try {
        entries.add(NavigationHistoryEntry.fromJson(
          Map<String, dynamic>.from(jsonDecode(encodedEntry) as Map),
        ));
      } catch (_) {
        // Ignore one malformed local item without hiding valid history.
      }
    }

    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return entries;
  }

  static Future<void> upsert(
    String username,
    NavigationHistoryEntry entry,
  ) async {
    final entries = await load(username);
    final existingIndex = entries.indexWhere((item) => item.id == entry.id);
    if (existingIndex == -1) {
      entries.add(entry);
    } else {
      entries[existingIndex] = entry;
    }
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _save(username, entries.take(_maximumEntries).toList());
  }

  static Future<void> delete(String username, String id) async {
    final entries = await load(username);
    entries.removeWhere((entry) => entry.id == id);
    await _save(username, entries);
  }

  static Future<void> clear(String username) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey(username));
  }

  static Future<void> _save(
    String username,
    List<NavigationHistoryEntry> entries,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _storageKey(username),
      entries.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }
}
