import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telephony/telephony.dart' as telephony;

import '/config/env_config.dart';
import '/core/algorithms.dart' as alogo_;
import '/data/sample_sms_data.dart';

// Helper class for the provider
class ReminderInfo {
  final SmsMessage message;
  final DateTime eventDate;
  ReminderInfo({required this.message, required this.eventDate});
}

class ReminderProvider with ChangeNotifier {
  final telephony.Telephony _telephony = telephony.Telephony.instance;

  // --- Private State ---
  List<SmsMessage> _allMessages = [];
  List<ReminderInfo> _allReminders = [];
  bool _isLoading = false;

// --- NEW: Wellness State ---
  alogo_.WellnessSummary _wellnessSummary = alogo_.WellnessSummary();
  List<SmsMessage> _ePaperMessages = [];  

  // --- Public Getters ---
  bool get isLoading => _isLoading;
  List<SmsMessage> get allMessages => _allMessages;

  double get ecoScore => _wellnessSummary.ecoScore;
  int get papersSaved => _wellnessSummary.papersSaved;
  List<SmsMessage> get ePaperMessages => _ePaperMessages;  

  // This is the list for "All Reminders" (today + future)
  List<ReminderInfo> get upcomingReminders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allReminders
        .where((r) => !r.eventDate.isBefore(today)) // Today or later
        .toList();
  }

  // This is the list for "History" (past)
  List<ReminderInfo> get historyReminders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allReminders
        .where((r) => r.eventDate.isBefore(today)) // Strictly before today
        .toList();
  }

  // This is the count for the badge
  int get upcomingReminderCount => upcomingReminders.length;

  // --- Data Fetching Method ---
  Future<void> fetchAndParseReminders() async {
    _isLoading = true;
    notifyListeners();

    List<SmsMessage> loadedMessages = [];
    if (EnvironmentConfig.isTestMode) {
      loadedMessages = sampleSmsList;
    } else {
      bool? perms = await _telephony.requestSmsPermissions;
      if (perms != true) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      List<telephony.SmsMessage> inbox = await _telephony.getInboxSms(
        columns: [
          telephony.SmsColumn.ADDRESS,
          telephony.SmsColumn.BODY,
          telephony.SmsColumn.DATE,
          telephony.SmsColumn.TYPE,
        ],
      );
      List<telephony.SmsMessage> sent = await _telephony.getSentSms(
        columns: [
          telephony.SmsColumn.ADDRESS,
          telephony.SmsColumn.BODY,
          telephony.SmsColumn.DATE,
          telephony.SmsColumn.TYPE,
        ],
      );
      List<telephony.SmsMessage> liveSms = [...inbox, ...sent];
      liveSms.sort((a, b) => b.date!.compareTo(a.date!));

      int idCounter = 0;
      for (var liveMsg in liveSms) {
        if (liveMsg.body == null ||
            liveMsg.address == null ||
            liveMsg.date == null)
          continue;
        final analysis = alogo_.SmsAnalyzer().analyze(liveMsg.body!);
        loadedMessages.add(
          SmsMessage(
            id: 'live_${liveMsg.id ?? idCounter++}',
            sender: liveMsg.address!,
            body: liveMsg.body!,
            timestamp: DateTime.fromMillisecondsSinceEpoch(liveMsg.date!),
            category: analysis.category,
            sentiment: analysis.sentiment,
            transactionType: analysis.transactionType,
            isSent: liveMsg.type == telephony.SmsType.MESSAGE_TYPE_SENT,
          ),
        );
      }
    }

    _allMessages = loadedMessages;
    _allReminders = _extractReminders(_allMessages);

// --- NEW: PARSE WELLNESS DATA ---
    _wellnessSummary = alogo_.SmsAnalyzer.calculateWellnessSummary(
      _allMessages,
    );
    _ePaperMessages = _allMessages
        .where(
          (msg) =>
              msg.transactionType == alogo_.TransactionType.eBill ||
              (msg.body.toLowerCase().contains('http') &&
                  msg.category == alogo_.SmsCategory.transactions),
        )
        .toList();

    // Sort by event date (newest first)
    _allReminders.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    _isLoading = false;
    notifyListeners();
  }

  // --- Parsing Logic (with Date Fix) ---
  List<ReminderInfo> _extractReminders(List<SmsMessage> messages) {
    List<ReminderInfo> reminders = [];
    for (var msg in messages) {
      DateTime? eventDate;
      if (msg.transactionType == alogo_.TransactionType.bill) {
        eventDate = _parseDateFromText(
          msg.body,
          r'due (?:on |by )?([\w\s\d,]+)',
        );
      } else if (msg.transactionType == alogo_.TransactionType.travel) {
        eventDate = _parseDateFromText(msg.body, r'(?:for|on) ([\w\s\d,]+)');
      } else if (msg.transactionType == alogo_.TransactionType.delivery) {
        eventDate = _parseDateFromText(
          msg.body,
          r'(?:today|on|by) ([\w\s\d,]+)',
        );
      }

      if (eventDate != null) {
        reminders.add(ReminderInfo(message: msg, eventDate: eventDate));
      }
    }
    return reminders;
  }

  // --- THIS IS THE FIX FOR THE "HISTORY" BUG ---
  DateTime? _parseDateFromText(String body, String regexPattern) {
    final match = RegExp(regexPattern, caseSensitive: false).firstMatch(body);
    if (match == null || match.group(1) == null) return null;

    String dateString = match.group(1)!.trim();

    // Get 'now' at the start of the day for fair comparison
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Handle "today"
    if (dateString.toLowerCase() == 'today') return today;

    try {
      // Try full date first (e.g., 05-11-2025)
      return DateFormat('dd-MM-yyyy').parse(dateString);
    } catch (e) {
      // Try short date (e.g., "Nov 5")
      try {
        var parsedDate = DateFormat('MMM d').parse(dateString);
        // Construct date with current year
        var eventDate = DateTime(now.year, parsedDate.month, parsedDate.day);

        // If this date is > 1 month in the past (e.g., parsing "Jan 5" in "Nov 2"),
        // it's probably for next year.
        if (eventDate.isBefore(now.subtract(const Duration(days: 30)))) {
          eventDate = DateTime(now.year + 1, parsedDate.month, parsedDate.day);
        }
        return eventDate;
      } catch (e2) {
        return null;
      }
    }
  }
}
