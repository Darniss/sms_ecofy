import '/data/sample_sms_data.dart';

// --- Enums ---
enum Sentiment { happy, neutral, warning, sad, angry, spammy }

enum SmsCategory { personal, transactions, promotions, starred, other }

enum TransactionType {
  otp,
  order,
  travel,
  bank,
  bill,
  offer,
  spam,
  alert,
  social,
  none,
}

// --- Algorithm Stubs ---
// In a real app, these would contain complex logic or ML model inferences.
// This file is now expanded with more real-world keywords and logic.

class SmsAnalyzer {
  /// Analyzes the SMS body for its emotional tone.
  static Sentiment analyzeSentiment(String smsBody) {
    String body = smsBody.toLowerCase();

    // Spammy (high priority)
    if (body.contains('you have won') ||
        body.contains('lottery') ||
        body.contains('claim now') ||
        body.contains('100% free')) {
      return Sentiment.spammy;
    }

    // Angry / Urgent (often in failed transactions or final warnings)
    if (body.contains('legal action') ||
        body.contains('service suspended') ||
        body.contains('last warning')) {
      return Sentiment.angry;
    }

    // Warning
    if (body.contains('fraud') ||
        body.contains('risk') ||
        body.contains('overdue') ||
        body.contains('urgent') ||
        body.contains('action required') ||
        body.contains('suspicious') ||
        body.contains('unauthorized') ||
        body.contains('account balance is low')) {
      return Sentiment.warning;
    }

    // Sad (failed actions)
    if (body.contains('failed') ||
        body.contains('declined') ||
        body.contains('rejected') ||
        body.contains('unable to process') ||
        body.contains('payment failed')) {
      return Sentiment.sad;
    }

    // Happy
    if (body.contains('congratulations') ||
        body.contains('delivered') ||
        body.contains('confirmed') ||
        body.contains('credited') ||
        body.contains('offer accepted') ||
        body.contains('welcome') ||
        body.contains('successfully')) {
      return Sentiment.happy;
    }

    return Sentiment.neutral;
  }

  /// Maps a Sentiment enum to a displayable emoji.
  static String getEmojiForSentiment(Sentiment sentiment) {
    switch (sentiment) {
      case Sentiment.happy:
        return '😀';
      case Sentiment.warning:
        return '⚠️';
      case Sentiment.sad:
        return '😞';
      case Sentiment.angry:
        return '😠';
      case Sentiment.spammy:
        return '🚫';
      case Sentiment.neutral:
      default:
        return '😐';
    }
  }

  /// Categorizes the SMS based on its content.
  /// Note: A 'sender' is often an Alphanumeric ID like 'VM-HDFCBK'
  static SmsCategory categorizeSms(String sender, String smsBody) {
    String s = sender.toLowerCase();
    String b = smsBody.toLowerCase();

    // --- High-priority: Transactions ---
    // Check for common transaction keywords
    if (b.contains('otp') ||
        b.contains('one-time password') ||
        b.contains('verification code') ||
        b.contains('txn') ||
        b.contains('a/c') ||
        b.contains('acct') ||
        b.contains('credited') ||
        b.contains('debited') ||
        b.contains('balance is') ||
        b.contains('card ending') ||
        b.contains('due date') ||
        b.contains('bill generated') ||
        b.contains('order no.')) {
      return SmsCategory.transactions;
    }
    // Check for common transaction sender prefixes
    if (s.startsWith('vm-') ||
        s.startsWith('ad-') ||
        s.startsWith('tx-') ||
        s.startsWith('ax-') ||
        s.contains('bank') ||
        s.contains('hdfc') ||
        s.contains('icici') ||
        s.contains('sbi')) {
      return SmsCategory.transactions;
    }

    // --- Second priority: Promotions ---
    if (b.contains('offer') ||
        b.contains('sale') ||
        b.contains('discount') ||
        b.contains('cashback') ||
        b.contains('expires soon') ||
        b.contains('buy 1 get 1') ||
        b.contains('use code') ||
        b.contains('flat off') ||
        b.contains('limited time')) {
      return SmsCategory.promotions;
    }

    // --- Third priority: Personal ---
    // Check if sender is a phone number (e.g., +911234567890 or 1234567890)
    // This RegExp checks for 10-15 digits, optionally starting with a '+'
    if (RegExp(r'^\+?[0-9]{10,15}$').hasMatch(sender)) {
      // Check for common "spammy" content from numbers
      if (b.contains('lottery') ||
          b.contains('win cash') ||
          b.contains('click this link')) {
        return SmsCategory
            .promotions; // Or even a specific "spam" category if you add it
      }
      return SmsCategory.personal;
    }

    // If it's not a transaction and not from a number, it's likely a promotion or other service
    if (b.contains('sale') || b.contains('discount')) {
      return SmsCategory.promotions;
    }

    return SmsCategory.other;
  }

  /// Extracts a specific transaction type.
  static TransactionType getTransactionType(String sender, String smsBody) {
    String s = sender.toLowerCase();
    String b = smsBody.toLowerCase();

    // --- Priority 1: OTP ---
    if (b.contains('otp') ||
        b.contains('one-time password') ||
        b.contains('verification code') ||
        b.contains('security code') ||
        b.contains('v-code')) {
      return TransactionType.otp;
    }

    // --- Priority 2: Spam ---
    if (b.contains('win') ||
        b.contains('lottery') ||
        b.contains('spam') ||
        b.contains('claim reward') ||
        b.contains('dear user you have won') ||
        b.contains('click this link to win')) {
      return TransactionType.spam;
    }

    // --- Priority 3: Alerts ---
    if (b.contains('suspicious activity') ||
        b.contains('login attempt') ||
        b.contains('password reset') ||
        b.contains('unauthorized transaction') ||
        b.contains('service alert') ||
        b.contains('important notice')) {
      return TransactionType.alert;
    }

    // --- Priority 4: Orders ---
    if (s.contains('amazon') ||
        s.contains('flipkart') ||
        b.contains('order') ||
        s.contains('swiggy') ||
        s.contains('zomato') ||
        s.contains('meesho') ||
        s.contains('myntra') ||
        s.contains('zepto') ||
        b.contains('shipped') ||
        b.contains('delivered') ||
        b.contains('out for delivery') ||
        b.contains('order no.') ||
        b.contains('awb')) {
      return TransactionType.order;
    }

    // --- Priority 5: Travel ---
    if (s.contains('indigo') ||
        s.contains('airline') ||
        b.contains('flight') ||
        s.contains('ola') ||
        s.contains('uber') ||
        s.contains('rapido') ||
        s.contains('makemytrip') ||
        s.contains('goibibo') ||
        b.contains('pnr') ||
        b.contains('flight no.') ||
        b.contains('booking id') ||
        b.contains('check-in')) {
      return TransactionType.travel;
    }

    // --- Priority 6: Bank ---
    if (s.contains('bank') ||
        s.contains('hdfc') ||
        s.contains('icici') ||
        s.contains('sbi') ||
        s.contains('axis') ||
        s.contains('kotak') ||
        b.contains('a/c') ||
        b.contains('acct') ||
        b.contains('debited') ||
        b.contains('credited') ||
        b.contains('balance') ||
        b.contains('txn') ||
        b.contains('credit card') ||
        b.contains('debit card')) {
      return TransactionType.bank;
    }

    // --- Priority 7: Bill ---
    if (s.contains('airtel') ||
        s.contains('jio') ||
        s.contains('vodafone') ||
        s.contains('bses') ||
        s.contains('igl') ||
        b.contains('bill') ||
        b.contains('due date') ||
        b.contains('recharge') ||
        b.contains('electricity bill') ||
        b.contains('gas bill') ||
        b.contains('pay by')) {
      return TransactionType.bill;
    }

    // --- Priority 8: Social Media ---
    if (s.contains('facebook') ||
        s.contains('twitter') ||
        s.contains('linkedin') ||
        s.contains('instagram') ||
        b.contains('is your facebook code') ||
        b.contains('liked your post')) {
      return TransactionType.social;
    }

    // --- Priority 9: Offers (if not caught by promotion category) ---
    if (b.contains('offer') ||
        b.contains('sale') ||
        b.contains('discount') ||
        b.contains('cashback')) {
      return TransactionType.offer;
    }

    return TransactionType.none;
  }

  /// Calculates a Carbon Footprint score (e.g., higher for paperless bills).
  /// Stub logic: Score (0-100) based on number of e-bills.
  // --- FIX: Changed List<dynamic> to List<SmsMessage> ---
  static double calculateCarbonFootprint(List<SmsMessage> messages) {
    if (messages.isEmpty) return 0.0;
    // Assume each e-bill contributes 5 points, max 100
    double score =
        messages
            .where((m) => m.transactionType == TransactionType.bill)
            .length *
        5.0;
    return score.clamp(0.0, 100.0); // Clamp score between 0 and 100
  }

  /// Calculates a User Trust Score.
  /// Stub logic: Score (0-100) based on percentage of non-spam messages.
  // --- FIX: Changed List<dynamic> to List<SmsMessage> ---
  static double calculateTrustScore(List<SmsMessage> messages) {
    if (messages.isEmpty) return 50.0; // Default score if no messages

    int spamCount = messages
        .where(
          (m) =>
              m.transactionType == TransactionType.spam ||
              m.sentiment == Sentiment.spammy,
        )
        .length;

    double score = ((messages.length - spamCount) / messages.length) * 100.0;
    return score.clamp(0.0, 100.0);
  }

  /// Calculates a Privacy Insight Meter (PIM) score.
  /// Stub logic: Score (0-1A00) as a risk meter. More sensitive messages (bank, OTP) = higher risk score.
  // --- FIX: Changed List<dynamic> to List<SmsMessage> ---
  static double calculatePIM(List<SmsMessage> messages) {
    if (messages.isEmpty) return 0.0;

    // Weight sensitive messages
    int bankCount = messages
        .where((m) => m.transactionType == TransactionType.bank)
        .length;
    int otpCount = messages
        .where((m) => m.transactionType == TransactionType.otp)
        .length;

    // Give more weight to OTPs as they are higher risk
    double riskScore =
        ((bankCount * 1.0) + (otpCount * 2.0)) / messages.length * 100.0;

    return riskScore.clamp(0.0, 100.0); // Higher score = higher privacy risk
  }
}
