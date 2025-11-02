// import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _firstLaunchKey = 'isFirstLaunch';
  static const String _themeModeKey = 'themeMode';
  static const String _summaryLayoutKey = 'summaryLayout';
  static const String _summaryCardsKey = 'summaryCards';

  // --- NEW: Key for storing starred message IDs ---
  static const String _starredKey = 'starred_message_ids';

  static const String _pinnedKey = 'pinned_threads';
  static const String _mutedKey = 'muted_senders';  

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

// We use 'sender' as a proxy for 'thread_id'
  Future<void> setThreadPinned(String sender, bool isPinned) async {
    final prefs = await _getPrefs();
    List<String> pinned = prefs.getStringList(_pinnedKey) ?? [];
    if (isPinned) {
      if (!pinned.contains(sender)) {
        pinned.add(sender);
      }
    } else {
      pinned.remove(sender);
    }
    await prefs.setStringList(_pinnedKey, pinned);
  }

  Future<bool> isThreadPinned(String sender) async {
    final prefs = await _getPrefs();
    List<String> pinned = prefs.getStringList(_pinnedKey) ?? [];
    return pinned.contains(sender);
  }

  // --- NEW: Muting Logic ---
  Future<void> setSenderMuted(String sender, bool isMuted) async {
    final prefs = await _getPrefs();
    List<String> muted = prefs.getStringList(_mutedKey) ?? [];
    if (isMuted) {
      if (!muted.contains(sender)) {
        muted.add(sender);
      }
    } else {
      muted.remove(sender);
    }
    await prefs.setStringList(_mutedKey, muted);
  }

  Future<bool> isSenderMuted(String sender) async {
    final prefs = await _getPrefs();
    List<String> muted = prefs.getStringList(_mutedKey) ?? [];
    return muted.contains(sender);
  }  
}
