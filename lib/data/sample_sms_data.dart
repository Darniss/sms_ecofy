import '/core/algorithms.dart';

// A simple model for an SMS message
class SmsMessage {
  // --- NEW: Added 'id' and 'isStarred' ---
  final String id;
  final bool isSent;
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
    this.isSent = false,
    required this.sentiment,
    required this.transactionType,
    this.isStarred = false, // --- NEW ---
  });
}

class SmsAnalyzer {
  static SmsCategory getCategory(String body) {
    // Add your real categorization logic here
    if (body.toLowerCase().contains('order')) return SmsCategory.transactions;
    if (body.toLowerCase().contains('offer')) return SmsCategory.promotions;
    return SmsCategory.personal;
  }

  static Sentiment getSentiment(String body) {
    // Add your real sentiment logic here
    if (body.toLowerCase().contains('congratulations')) return Sentiment.happy;
    if (body.toLowerCase().contains('low balance')) return Sentiment.warning;
    return Sentiment.neutral;
  }

  static TransactionType getTransactionType(String body) {
    // Add your real transaction logic here
    if (body.toLowerCase().contains('order')) return TransactionType.order;
    if (body.toLowerCase().contains('otp')) return TransactionType.otp;
    if (body.toLowerCase().contains('flight')) return TransactionType.travel;
    return TransactionType.none;
  }

  static String getEmojiForSentiment(Sentiment sentiment) {
    switch (sentiment) {
      case Sentiment.happy:
        return '😊';
      case Sentiment.warning:
        return '⚠️';
      case Sentiment.neutral:
      default:
        return '💬';
    }
  }
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
  SmsMessage(
    id: '9', // --- NEW ---
    sender: 'BlueDart',
    body:
        'Your package 12345 is out for delivery and will arrive today, Nov 2.',
    timestamp: DateTime(2025, 11, 2, 9, 00), // Today (Nov 2)
    category: SmsCategory.transactions,
    sentiment: Sentiment.happy,
    transactionType: TransactionType.delivery,
  ),
  SmsMessage(
    id: '10', // --- NEW ---
    sender: 'HDFC Bank',
    body:
        'Your credit card e-statement for Oct 2025 is ready. Download it here: https://www.africau.edu/images/sample.pdf',
    timestamp: DateTime(2025, 10, 28, 14, 00),
    category: SmsCategory.transactions,
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.eBill,
  ),
  SmsMessage(
    id: '11', // --- NEW ---
    sender: 'Airtel',
    body:
        'Your e-bill for 9876543210 is generated. View and pay your bill here: https://example.com/my-bill',
    timestamp: DateTime(2025, 10, 20, 11, 00),
    category: SmsCategory.transactions,
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.eBill,
  ),
  SmsMessage(
    id: '12', // --- NEW ---
    sender: 'Amazon',
    body:
        'Your order 123-456 has been delivered. View your e-invoice at https://www.google.com/search?q=invoice',
    timestamp: DateTime(2025, 11, 1, 19, 00), // Yesterday
    category: SmsCategory.transactions,
    sentiment: Sentiment.happy,
    transactionType:
        TransactionType.order, // Not an eBill, but still has a link
  ),  
  SmsMessage(
    id: '4', // This one from your original list is a future reminder
    sender: 'Airtel',
    body: 'Your bill for Rs. 499 is due on Nov 5.',
    timestamp: DateTime(2025, 10, 31, 10, 00), // Yesterday (Oct 31)
    category: SmsCategory.transactions,
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.bill,
  ),
  SmsMessage(
    id: '13',
    sender: 'VM-HDFCBK',
    body:
        'Your A/c xx...1234 has been credited with Rs. 15,000.00. Your new available balance is Rs. 55,000.00.',
    timestamp: DateTime(2025, 11, 2, 10, 00), // Today (Nov 2)
    category: SmsCategory.transactions,
    sentiment: Sentiment.happy,
    transactionType: TransactionType.bank,
  ),
  SmsMessage(
    id: '14',
    sender: 'AD-ICICI',
    body:
        'Your credit card CC...5678 has a new e-statement. Total amount due: Rs. 8,250.00. Min due: Rs. 500.00.',
    timestamp: DateTime(2025, 11, 1, 14, 00), // Yesterday
    category: SmsCategory.transactions,
    sentiment: Sentiment.warning,
    transactionType: TransactionType.bill, // This will be re-classified
  ),
  SmsMessage(
    id: '15',
    sender: 'VM-HDFCBK',
    body:
        'Your A/c xx...1234 has been debited by Rs. 5,000.00. Your available balance is Rs. 40,000.00.',
    timestamp: DateTime(2025, 10, 30, 18, 00), // An older message
    category: SmsCategory.transactions,
    sentiment: Sentiment.neutral,
    transactionType: TransactionType.bank,
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
