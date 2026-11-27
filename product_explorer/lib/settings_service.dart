import 'package:shared_preferences/shared_preferences.dart';

/// Step 1 -- shared_preferences: small device settings, one value per key.
/// Every setting has one clearly named place to live; widgets and Blocs never
/// call SharedPreferences directly.
class SettingsService {
  static const _kDarkMode = 'dark_mode';
  static const _kLastCategory = 'last_category';

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
  }

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDarkMode) ?? false;
  }

  /// `null` means "All" -- the key is removed.
  Future<void> setLastCategory(String? category) async {
    final prefs = await SharedPreferences.getInstance();
    if (category == null) {
      await prefs.remove(_kLastCategory);
    } else {
      await prefs.setString(_kLastCategory, category);
    }
  }

  Future<String?> getLastCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastCategory);
  }
}
