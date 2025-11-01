// import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _firstLaunchKey = 'isFirstLaunch';
  static const String _themeModeKey = 'themeMode';
  static const String _summaryLayoutKey = 'summaryLayout';
  static const String _summaryCardsKey = 'summaryCards';

  // --- NEW: Key for storing starred message IDs ---
  static const String _starredKey = 'starred_message_ids';

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

  // --- NEW: Starred Messages ---

  /// Adds or removes a message ID from the list of starred messages.
  Future<void> starMessage(String id, bool isStarred) async {
    final prefs = await _getPrefs();
    List<String> starredIds = prefs.getStringList(_starredKey) ?? [];

    if (isStarred) {
      if (!starredIds.contains(id)) {
        starredIds.add(id);
      }
    } else {
      starredIds.remove(id);
    }
    await prefs.setStringList(_starredKey, starredIds);
  }

  /// Retrieves the list of all starred message IDs.
  Future<List<String>> getStarredIds() async {
    final prefs = await _getPrefs();
    return prefs.getStringList(_starredKey) ?? [];
  }
}
