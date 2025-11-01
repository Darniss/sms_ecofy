// import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _firstLaunchKey = 'isFirstLaunch';
  // Removed: _dataModeKey
  static const String _themeModeKey = 'themeMode'; // 'light' or 'dark'
  static const String _summaryLayoutKey =
      'summaryLayout'; // 'grid', 'list', 'pie'
  static const String _summaryCardsKey = 'summaryCards'; // List<String>

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // --- First Launch ---
  Future<bool> isFirstLaunch() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunchDone() async {
    final prefs = await _getPrefs();
    await prefs.setBool(_firstLaunchKey, false);
  }

  // --- Theme Mode ---
  Future<void> setThemeMode(String mode) async {
    final prefs = await _getPrefs();
    await prefs.setString(_themeModeKey, mode);
  }

  Future<String> getThemeMode() async {
    final prefs = await _getPrefs();
    return prefs.getString(_themeModeKey) ?? 'light';
  }

  // --- Summary Card Layout ---
  Future<void> setSummaryCardLayout(String layout) async {
    final prefs = await _getPrefs();
    await prefs.setString(_summaryLayoutKey, layout);
  }

  Future<String> getSummaryCardLayout() async {
    final prefs = await _getPrefs();
    return prefs.getString(_summaryLayoutKey) ?? 'grid';
  }

  // --- Summary Card Selection ---
  Future<void> setSummaryCardSelection(List<String> cards) async {
    final prefs = await _getPrefs();
    await prefs.setStringList(_summaryCardsKey, cards);
  }

  Future<List<String>> getSummaryCardSelection() async {
    final prefs = await _getPrefs();
    return prefs.getStringList(_summaryCardsKey) ?? [];
  }
}
