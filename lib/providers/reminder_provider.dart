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

  List<alogo_.FinancialAccount> _bankAccounts = [];
  List<alogo_.FinancialAccount> _creditCards = [];

  // --- FIX 1: Set isLoading to true by default ---
  // This ensures the UI shows a loading circle on the first frame
  // instead of trying to build with null data.
  bool _isLoading = true;

  // --- FIX 2: Ensure all summary objects are initialized ---
  // This guarantees they are NEVER null, even before loading.
  alogo_.WellnessSummary _wellnessSummary = alogo_.WellnessSummary();
  alogo_.PrivacySummary _privacySummary = alogo_.PrivacySummary();
  // --- END FIXES ---

  List<SmsMessage> _ePaperMessages = [];
  List<SmsMessage> _spamMessages = [];
  List<SmsMessage> _subscriptionMessages = [];

  // --- Public Getters ---
  bool get isLoading => _isLoading;
  List<SmsMessage> get allMessages => _allMessages;

  // Reminder Getters
  List<ReminderInfo> get upcomingReminders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allReminders.where((r) => !r.eventDate.isBefore(today)).toList();
  }

  List<alogo_.FinancialAccount> get bankAccounts => _bankAccounts;
  List<alogo_.FinancialAccount> get creditCards => _creditCards;

  List<ReminderInfo> get historyReminders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allReminders.where((r) => r.eventDate.isBefore(today)).toList();
  }

  int get upcomingReminderCount => upcomingReminders.length;

  // Wellness Getters
  double get ecoScore => _wellnessSummary.ecoScore;
  int get papersSaved => _wellnessSummary.papersSaved;
  List<SmsMessage> get ePaperMessages => _ePaperMessages;

  // Privacy Getters
  alogo_.PrivacySummary get privacySummary => _privacySummary;
  List<SmsMessage> get spamMessages => _spamMessages;
  List<SmsMessage> get subscriptionMessages => _subscriptionMessages;

  // --- Data Fetching Method ---
  Future<void> fetchAndParseReminders() async {
    // We are already loading, so no need to set _isLoading = true here

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

    // --- PARSE ALL DATA ---
    _allReminders = _extractReminders(_allMessages);
    _allReminders.sort((a, b) => b.eventDate.compareTo(a.eventDate));

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

    _privacySummary = alogo_.SmsAnalyzer.calculatePrivacySummary(_allMessages);
    _spamMessages = _allMessages
        .where((m) => m.transactionType == alogo_.TransactionType.spam)
        .toList();
    _subscriptionMessages = _allMessages
        .where((m) => m.transactionType == alogo_.TransactionType.subscription)
        .toList();
    // --- END PARSING ---

    var financialData = alogo_.SmsAnalyzer.parseFinancialAccounts(_allMessages);
    _bankAccounts = financialData['accounts'] ?? [];
    _creditCards = financialData['cards'] ?? [];

    _isLoading = false; // <-- Now we are done loading
    notifyListeners(); // Tell all screens to rebuild with the new data
  }

  // --- Reminder Parsing Logic ---
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

  DateTime? _parseDateFromText(String body, String regexPattern) {
    final match = RegExp(regexPattern, caseSensitive: false).firstMatch(body);
    if (match == null || match.group(1) == null) return null;

    String dateString = match.group(1)!.trim();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (dateString.toLowerCase() == 'today') return today;

    try {
      return DateFormat('dd-MM-yyyy').parse(dateString);
    } catch (e) {
      try {
        var parsedDate = DateFormat('MMM d').parse(dateString);
        var eventDate = DateTime(now.year, parsedDate.month, parsedDate.day);

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
