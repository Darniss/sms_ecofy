import '/core/algorithms.dart';

// A simple model for an SMS message
class SmsMessage {
  final String sender;
  final String body;
  final DateTime timestamp;
  final SmsCategory category;
  final Sentiment sentiment;
  final TransactionType transactionType;

  SmsMessage({
    required this.sender,
    required this.body,
    required this.timestamp,
    required this.category,
    required this.sentiment,
    required this.transactionType,
  });
}

// Sample data list using the new enums
final List<SmsMessage> sampleSmsList = [
  SmsMessage(
    sender: 'Amazon',
    body: 'Your order for "Eco-Friendly Water Bottle" has been shipped!',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    category: SmsCategory.transactions,
    sentiment: Sentiment.happy,
    transactionType: TransactionType.order,
  ),
  SmsMessage(
    sender: 'HDFC Bank',
    body: 'Your account balance is low. Please add funds.',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    category: SmsCategory.transactions,
    sentiment: Sentiment.warning,
    transactionType: TransactionType.bank,
  ),
  SmsMessage(
    sender: '+91 1234567890',
    body: 'Hey! Are you coming over for dinner tonight?',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    category: SmsCategory.personal,
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.none,
  ),
  SmsMessage(
    sender: 'Airtel',
    body: 'Your bill for Rs. 499 is due on Nov 5.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    category: SmsCategory.transactions,
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.bill,
  ),
  SmsMessage(
    sender: 'VM-SWIGGY',
    body: 'FLAT 50% OFF on your next 3 orders. Use code: EAT50',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    category: SmsCategory.promotions,
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.offer,
  ),
  SmsMessage(
    sender: 'IndiGo',
    body: 'Your flight 6E-204 from DEL to BOM is confirmed for Oct 30.',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    category: SmsCategory.transactions,
    sentiment: Sentiment.happy,
    transactionType: TransactionType.travel,
  ),
  SmsMessage(
    sender: 'TX-Lottery',
    body:
        'Congratulations! You have won a 1,000,000 lottery. Click here to claim.',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    category: SmsCategory.promotions,
    sentiment: Sentiment.warning,
    transactionType: TransactionType.spam,
  ),
  // --- NEW OTP MESSAGE ---
  SmsMessage(
    sender: 'VM-GOOGLE',
    body: 'Your Google verification code is 123456. Do not share it.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    category: SmsCategory.transactions, // Still a transaction
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.otp, // Specifically OTP
  ),
];

// Sample summary data with new categories
// In a real app, this would be calculated.
final Map<String, int> summaryData = {
  'offers': 3,
  'orders': 2,
  'travel': 1,
  'alerts': 1,
  'spam': 5,
  'pim': 75, // Assuming PIM is a score 0-100
  'carbon': 40, // Assuming Carbon Score is 0-100
  'trust': 85, // Assuming Trust Score is 0-100
};
