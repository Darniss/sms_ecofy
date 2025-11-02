import '/core/algorithms.dart';

// --- NEW: Enum for message type ---
enum SmsMessageType { sent, received, draft }

class SmsMessage {
  final String id;
  // --- NEW: This is the key to grouping messages correctly ---
  final int? threadId;
  final String sender;
  final String body;
  final DateTime timestamp;
  final SmsMessageType type; // <-- NEW
  final SmsCategory category;
  final Sentiment sentiment;
  final TransactionType transactionType;
  bool isStarred;

  SmsMessage({
    required this.id,
    this.threadId, // <-- NEW
    required this.sender,
    required this.body,
    required this.timestamp,
    required this.type, // <-- NEW
    required this.category,
    required this.sentiment,
    required this.transactionType,
    this.isStarred = false,
  });
}
