import 'package:flutter/material.dart';
import '/data/sample_sms_data.dart';
import '/core/algorithms.dart';
import '/utils/storage_service.dart';
import '/config/env_config.dart';

class SmsProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  // Data
  List<SmsMessage> _allMessages = [];
  Map<String, int> _summary = {};

  // State
  bool _isLoading = true;

  // Getters
  List<SmsMessage> get allMessages => _allMessages;
  Map<String, int> get summary => _summary;
  bool get isLoading => _isLoading;

  SmsProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate data fetching
    await Future.delayed(const Duration(milliseconds: 500));

    List<SmsMessage> loadedMessages = [];
    if (EnvironmentConfig.isTestMode) {
      loadedMessages = sampleSmsList;
      _summary = summaryData;
    } else {
      // TODO: Add logic to fetch real SMS messages
      // For now, we'll use sample data
      loadedMessages = sampleSmsList;
      _summary = summaryData;
    }

    // Load starred status
    final starredIds = await _storageService.getStarredIds();
    for (var msg in loadedMessages) {
      if (starredIds.contains(msg.id)) {
        msg.isStarred = true;
      }
    }

    _allMessages = loadedMessages;
    _isLoading = false;
    notifyListeners();
  }

  // --- Actions ---

  Future<void> toggleStar(SmsMessage message) async {
    message.isStarred = !message.isStarred;
    await _storageService.starMessage(message.id, message.isStarred);
    notifyListeners();
  }

  Future<void> deleteMessage(SmsMessage message) async {
    final int masterIndex = _allMessages.indexOf(message);
    if (masterIndex == -1) return;

    _allMessages.removeAt(masterIndex);
    // TODO: You would also recalculate summary here
    notifyListeners();
    // TODO: Add to local storage for permanent deletion if needed
  }

  Future<void> undoDelete(SmsMessage message, int masterIndex) async {
    if (masterIndex <= _allMessages.length) {
      _allMessages.insert(masterIndex, message);
    } else {
      _allMessages.add(message);
    }
    // TODO: You would also recalculate summary here
    notifyListeners();
  }
}
