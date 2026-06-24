import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/website.dart';
import '../models/favorite.dart';
import '../models/settings.dart';
import 'encryption_service.dart';

class PrivacyLink {
  final String name;
  final String url;

  PrivacyLink({required this.name, required this.url});
}

class StorageService {
  static const String _favoritesBox = 'favorites';
  static const String _settingsBox = 'settings';
  static const String _websitesBox = 'websites';
  static const String _historyBox = 'history';
  static Map<String, dynamic> _defaultConfig = {};

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_favoritesBox);
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_websitesBox);
    await Hive.openBox(_historyBox);
    try {
      final jsonString = await rootBundle.loadString('assets/app_config.json');
      _defaultConfig = Map<String, dynamic>.from(json.decode(jsonString));
    } catch (_) {}
  }

  // Websites
  static Future<List<Website>> loadWebsites() async {
    final builtIn = await loadBuiltInWebsites();
    final custom = await getCustomWebsites();
    final customIds = custom.map((w) => w.id).toSet();
    builtIn.removeWhere((w) => customIds.contains(w.id));
    return [...builtIn, ...custom];
  }

  static Future<List<Website>> loadBuiltInWebsites() async {
    try {
      final jsonString = await rootBundle.loadString('assets/websites.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Website.fromJson(Map<String, dynamic>.from(json))).toList();
    } catch (e) {
      debugPrint('Failed to load built-in websites: $e');
      return [];
    }
  }

  // Favorites
  static List<Favorite> getFavorites() {
    final box = Hive.box(_favoritesBox);
    final List<dynamic> data = box.get('list', defaultValue: []);
    return data.map((json) => Favorite.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  static Future<void> addFavorite(Favorite favorite) async {
    final box = Hive.box(_favoritesBox);
    final List<dynamic> data = box.get('list', defaultValue: []);
    data.add(favorite.toJson());
    await box.put('list', data);
  }

  static Future<void> removeFavorite(String websiteId) async {
    final box = Hive.box(_favoritesBox);
    final List<dynamic> data = box.get('list', defaultValue: []);
    data.removeWhere((json) => json['websiteId'] == websiteId);
    await box.put('list', data);
  }

  // Settings
  static Settings getSettings() {
    final box = Hive.box(_settingsBox);
    final dynamic rawData = box.get('settings', defaultValue: {});
    final Map<String, dynamic> hiveData = Map<String, dynamic>.from(rawData);
    final merged = Map<String, dynamic>.from(_defaultConfig);
    merged.addAll(hiveData);
    if (merged.containsKey('privacyPassword')) {
      final decrypted = EncryptionService.decryptText(merged['privacyPassword'] as String);
      if (decrypted.isNotEmpty) {
        merged['privacyPassword'] = decrypted;
      } else {
        merged.remove('privacyPassword');
      }
    }
    return Settings.fromJson(merged);
  }

  static Future<void> saveSettings(Settings settings) async {
    final data = settings.toJson();
    data['privacyPassword'] = EncryptionService.encryptText(settings.privacyPassword);
    final box = Hive.box(_settingsBox);
    await box.put('settings', data);
  }

  // Developer mode
  static bool _isDeveloperMode = false;
  static bool get isDeveloperMode => _isDeveloperMode;

  static bool unlockDeveloperMode(String key) {
    if (key == EncryptionService.developerKey) {
      _isDeveloperMode = true;
      return true;
    }
    return false;
  }

  static void exitDeveloperMode() {
    _isDeveloperMode = false;
  }

  // Custom websites (for developer mode)
  static Future<List<Website>> getCustomWebsites() async {
    final box = Hive.box(_websitesBox);
    final dynamic rawData = box.get('customList', defaultValue: []);
    final List<dynamic> data = List<dynamic>.from(rawData);
    return data.map((json) => Website.fromJson(Map<String, dynamic>.from(json))).toList();
  }

  static Future<void> addCustomWebsite(Website website) async {
    final box = Hive.box(_websitesBox);
    final dynamic rawData = box.get('customList', defaultValue: []);
    final List<dynamic> data = List<dynamic>.from(rawData);
    data.add(website.toJson());
    await box.put('customList', data);
  }

  static Future<void> removeCustomWebsite(String websiteId) async {
    final box = Hive.box(_websitesBox);
    final dynamic rawData = box.get('customList', defaultValue: []);
    final List<dynamic> data = List<dynamic>.from(rawData);
    data.removeWhere((json) => Map<String, dynamic>.from(json)['id'] == websiteId);
    await box.put('customList', data);
  }

  static Future<void> updateCustomWebsite(Website website) async {
    final box = Hive.box(_websitesBox);
    final dynamic rawData = box.get('customList', defaultValue: []);
    final List<dynamic> data = List<dynamic>.from(rawData);
    final index = data.indexWhere((json) => Map<String, dynamic>.from(json)['id'] == website.id);
    if (index != -1) {
      data[index] = website.toJson();
      await box.put('customList', data);
    }
  }

  // App config from assets
  static Future<Map<String, dynamic>> loadAppConfig() async {
    try {
      final jsonString = await rootBundle.loadString('assets/app_config.json');
      return Map<String, dynamic>.from(json.decode(jsonString));
    } catch (e) {
      return {};
    }
  }

  static String getDefaultUpdateUrl() {
    // The app_config is loaded asynchronously; this is a sync fallback.
    // The actual loading happens at startup and the value is merged into settings.
    return '';
  }

  // Privacy links from assets
  static Future<List<PrivacyLink>> loadDefaultPrivacyLinks() async {
    try {
      final text = await rootBundle.loadString('assets/privacy_links.txt');
      final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();
      return lines.map((line) {
        final colonIdx = line.indexOf('：');
        final halfColonIdx = line.indexOf(':');
        final splitAt = colonIdx >= 0 && (halfColonIdx < 0 || colonIdx < halfColonIdx)
            ? colonIdx
            : halfColonIdx;
        if (splitAt < 0) return PrivacyLink(name: line.trim(), url: '');
        return PrivacyLink(
          name: line.substring(0, splitAt).trim(),
          url: line.substring(splitAt + 1).trim(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Custom privacy links (added via developer mode)
  static List<PrivacyLink> getCustomPrivacyLinks() {
    final box = Hive.box(_websitesBox);
    final rawData = box.get('privacyCustomLinks', defaultValue: []);
    final data = List<Map<String, dynamic>>.from(
      (rawData as List).map((e) => Map<String, dynamic>.from(e)),
    );
    return data.map((e) => PrivacyLink(name: e['name'] ?? '', url: e['url'] ?? '')).toList();
  }

  static Future<void> addCustomPrivacyLink(String name, String url) async {
    final box = Hive.box(_websitesBox);
    final rawData = box.get('privacyCustomLinks', defaultValue: []);
    final data = List<dynamic>.from(rawData);
    data.add({'name': name, 'url': url});
    await box.put('privacyCustomLinks', data);
  }

  static Future<void> removeCustomPrivacyLink(int index) async {
    final box = Hive.box(_websitesBox);
    final rawData = box.get('privacyCustomLinks', defaultValue: []);
    final data = List<dynamic>.from(rawData);
    if (index >= 0 && index < data.length) {
      data.removeAt(index);
      await box.put('privacyCustomLinks', data);
    }
  }

  // Browsing history
  static List<Map<String, String>> getHistory() {
    final box = Hive.box(_historyBox);
    final rawData = box.get('history', defaultValue: []);
    return List<Map<String, String>>.from(
      (rawData as List).map((e) => Map<String, String>.from(e)),
    );
  }

  static Future<void> addHistory(String title, String url) async {
    final box = Hive.box(_historyBox);
    final history = getHistory();
    history.removeWhere((e) => e['url'] == url);
    history.insert(0, {'title': title, 'url': url, 'time': DateTime.now().toIso8601String()});
    if (history.length > 100) history.removeLast();
    await box.put('history', history);
  }

  static Future<void> clearHistory() async {
    final box = Hive.box(_historyBox);
    await box.put('history', []);
  }
}