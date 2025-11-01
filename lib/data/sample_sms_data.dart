import '/core/algorithms.dart';

// A simple model for an SMS message
class SmsMessage {
  // --- NEW: Added 'id' and 'isStarred' ---
  final String id;
  final String sender;
  final String body;
  final DateTime timestamp;
  final SmsCategory category;
  final Sentiment sentiment;
  final TransactionType transactionType;
  bool isStarred;

  SmsMessage({
    required this.id, // --- NEW ---
    required this.sender,
    required this.body,
    required this.timestamp,
    required this.category,
    required this.sentiment,
    required this.transactionType,
    this.isStarred = false, // --- NEW ---
  });
}

// --- UPDATED: Sample data with fixed timestamps and new fields ---
// Using fixed dates is crucial for testing the time filters.
final List<SmsMessage> sampleSmsList = [
  SmsMessage(
    id: '1', // --- NEW ---
    sender: 'Amazon',
    body: 'Your order for "Eco-Friendly Water Bottle" has been shipped!',
    timestamp: DateTime(2025, 11, 1, 18, 00), // Today (Nov 1)
    category: SmsCategory.transactions,
    sentiment: Sentiment.happy,
    transactionType: TransactionType.order,
  ),
  SmsMessage(
    id: '2', // --- NEW ---
    sender: 'HDFC Bank',
    body: 'Your account balance is low. Please add funds.',
    timestamp: DateTime(2025, 11, 1, 15, 00), // Today (Nov 1)
    category: SmsCategory.transactions,
    sentiment: Sentiment.warning,
    transactionType: TransactionType.bank,
  ),
  SmsMessage(
    id: '3', // --- NEW ---
    sender: '+91 1234567890',
    body: 'Hey! Are you coming over for dinner tonight?',
    timestamp: DateTime(2025, 10, 31, 19, 00), // Yesterday (Oct 31)
    category: SmsCategory.personal,
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.none,
  ),
  SmsMessage(
    id: '4', // --- NEW ---
    sender: 'Airtel',
    body: 'Your bill for Rs. 499 is due on Nov 5.',
    timestamp: DateTime(2025, 10, 31, 10, 00), // Yesterday (Oct 31)
    category: SmsCategory.transactions,
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.bill,
  ),
  SmsMessage(
    id: '5', // --- NEW ---
    sender: 'VM-SWIGGY',
    body: 'FLAT 50% OFF on your next 3 orders. Use code: EAT50',
    timestamp: DateTime(2025, 10, 30, 14, 00), // Oct 30
    category: SmsCategory.promotions,
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.offer,
  ),
  SmsMessage(
    id: '6', // --- NEW ---
    sender: 'IndiGo',
    body: 'Your flight 6E-204 from DEL to BOM is confirmed for Oct 30.',
    timestamp: DateTime(2025, 10, 30, 9, 00), // Oct 30
    category: SmsCategory.transactions,
    sentiment: Sentiment.happy,
    transactionType: TransactionType.travel,
    isStarred: true, // Example of a pre-starred message
  ),
  SmsMessage(
    id: '7', // --- NEW ---
    sender: 'TX-Lottery',
    body:
        'Congratulations! You have won a 1,000,000 lottery. Click here to claim.',
    timestamp: DateTime(2025, 10, 20, 11, 00), // Last month (Oct)
    category: SmsCategory.promotions,
    sentiment: Sentiment.warning,
    transactionType: TransactionType.spam,
  ),
  SmsMessage(
    id: '8', // --- NEW ---
    sender: 'VM-GOOGLE',
    body: 'Your Google verification code is 123456. Do not share it.',
    timestamp: DateTime(2025, 9, 15, 12, 00), // September
    category: SmsCategory.transactions,
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.otp,
  ),
];

// Sample summary data (your existing data)
final Map<String, int> summaryData = {
  'offers': 3,
  'orders': 2,
  'travel': 1,
  'alerts': 1,
  'spam': 5,
  'pim': 75,
  'carbon': 40,
  'trust': 85,
};
