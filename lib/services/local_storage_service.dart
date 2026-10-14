import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_data.dart';

class LocalStorageService {
  // Keep the storage identifier stable across the baiqau rebrand.
  static const key = 'baiqa_data_v1';
  Future<AppData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) {
      return null;
    }
    return AppData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> save(AppData data) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(key, jsonEncode(data.toJson()));
    if (!saved) {
      throw StateError('Деректер сақталмады.');
    }
  }
}
