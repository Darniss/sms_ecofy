import '/data/sample_sms_data.dart';

// // --- Enums ---
// enum Sentiment { happy, neutral, warning, sad, angry, spammy }

// enum SmsCategory { personal, transactions, promotions, starred, other }

// enum TransactionType {
//   otp,
//   order,
//   travel,
//   bank,
//   bill,
//   offer,
//   spam,
//   alert,
//   social,
//   none,
// }



// // --- 2. A HELPER CLASS TO HOLD THE ANALYSIS RESULT ---

// class AnalysisResult {
//   final SmsCategory category;
//   final Sentiment sentiment;
//   final TransactionType transactionType;

//   AnalysisResult({
//     required this.category,
//     required this.sentiment,
//     required this.transactionType,
//   });
// }

// // --- Algorithm Stubs ---
// // In a real app, these would contain complex logic or ML model inferences.
// // This file is now expanded with more real-world keywords and logic.

// class SmsAnalyzer {
//   /// Analyzes the SMS body for its emotional tone.
//   static Sentiment analyzeSentiment(String smsBody) {
//     String body = smsBody.toLowerCase();

//     AnalysisResult analyze(String body) {
//     String lowerBody = body.toLowerCase();

// // Rule 1: OTP
//       if (lowerBody.contains('otp') ||
//           lowerBody.contains('verification code') ||
//           (lowerBody.contains('code is') && lowerBody.length < 100)) {
//         return AnalysisResult(
//           category: SmsCategory.transactions,
//           sentiment: Sentiment.neutral,
//           transactionType: TransactionType.otp,
//         );
//       }

//       // Rule 2: Order / Shipping
//       if (lowerBody.contains('order') ||
//           lowerBody.contains('shipped') ||
//           lowerBody.contains('delivered') ||
//           lowerBody.contains('out for delivery')) {
//         return AnalysisResult(
//           category: SmsCategory.transactions,
//           sentiment: Sentiment.happy,
//           transactionType: TransactionType.order,
//         );
//       }

//       // Rule 3: Offers
//       if (lowerBody.contains('offer') ||
//           lowerBody.contains('discount') ||
//           lowerBody.contains('% off') ||
//           lowerBody.contains('sale')) {
//         return AnalysisResult(
//           category: SmsCategory.promotions,
//           sentiment: Sentiment.neutral,
//           transactionType: TransactionType.offer,
//         );
//       }

//       // Rule 4: Spam
//       if (lowerBody.contains('congratulations') ||
//           lowerBody.contains('you have won') ||
//           lowerBody.contains('lottery') ||
//           lowerBody.contains('click here')) {
//         return AnalysisResult(
//           category: SmsCategory.promotions,
//           sentiment: Sentiment.warning,
//           transactionType: TransactionType.spam,
//         );
//       }

//       // Rule 5: Bank Transactions
//       if (lowerBody.contains('debited') ||
//           lowerBody.contains('credited') ||
//           lowerBody.contains('a/c') ||
//           lowerBody.contains('rs.') ||
//           lowerBody.contains('balance is')) {
//         Sentiment sentiment = Sentiment.neutral;
//         if (lowerBody.contains('low balance')) sentiment = Sentiment.warning;
//         if (lowerBody.contains('credited')) sentiment = Sentiment.happy;

//         return AnalysisResult(
//           category: SmsCategory.transactions,
//           sentiment: sentiment,
//           transactionType: TransactionType.bank,
//         );
//       }
// // --- Default: Personal ---
//       // If no other rules match, assume it's personal
//       return AnalysisResult(
//         category: SmsCategory.personal,
//         sentiment: Sentiment.neutral,
//         transactionType: TransactionType.none,
//       );
//     }

//     // Spammy (high priority)
//     if (body.contains('you have won') ||
//         body.contains('lottery') ||
//         body.contains('claim now') ||
//         body.contains('100% free')) {
//       return Sentiment.spammy;
//     }

//     // Angry / Urgent (often in failed transactions or final warnings)
//     if (body.contains('legal action') ||
//         body.contains('service suspended') ||
//         body.contains('last warning')) {
//       return Sentiment.angry;
//     }

//     // Warning
//     if (body.contains('fraud') ||
//         body.contains('risk') ||
//         body.contains('overdue') ||
//         body.contains('urgent') ||
//         body.contains('action required') ||
//         body.contains('suspicious') ||
//         body.contains('unauthorized') ||
//         body.contains('account balance is low')) {
//       return Sentiment.warning;
//     }

//     // Sad (failed actions)
//     if (body.contains('failed') ||
//         body.contains('declined') ||
//         body.contains('rejected') ||
//         body.contains('unable to process') ||
//         body.contains('payment failed')) {
//       return Sentiment.sad;
//     }

//     // Happy
//     if (body.contains('congratulations') ||
//         body.contains('delivered') ||
//         body.contains('confirmed') ||
//         body.contains('credited') ||
//         body.contains('offer accepted') ||
//         body.contains('welcome') ||
//         body.contains('successfully')) {
//       return Sentiment.happy;
//     }

//     return Sentiment.neutral;
//   }

//   /// Maps a Sentiment enum to a displayable emoji.
//   static String getEmojiForSentiment(Sentiment sentiment) {
//     switch (sentiment) {
//       case Sentiment.happy:
//         return '😀';
//       case Sentiment.warning:
//         return '⚠️';
//       case Sentiment.sad:
//         return '😞';
//       case Sentiment.angry:
//         return '😠';
//       case Sentiment.spammy:
//         return '🚫';
//       case Sentiment.neutral:
//       default:
//         return '😐';
//     }
//   }

//   /// Categorizes the SMS based on its content.
//   /// Note: A 'sender' is often an Alphanumeric ID like 'VM-HDFCBK'
//   static SmsCategory categorizeSms(String sender, String smsBody) {
//     String s = sender.toLowerCase();
//     String b = smsBody.toLowerCase();

//     // --- High-priority: Transactions ---
//     // Check for common transaction keywords
//     if (b.contains('otp') ||
//         b.contains('one-time password') ||
//         b.contains('verification code') ||
//         b.contains('txn') ||
//         b.contains('a/c') ||
//         b.contains('acct') ||
//         b.contains('credited') ||
//         b.contains('debited') ||
//         b.contains('balance is') ||
//         b.contains('card ending') ||
//         b.contains('due date') ||
//         b.contains('bill generated') ||
//         b.contains('order no.')) {
//       return SmsCategory.transactions;
//     }
//     // Check for common transaction sender prefixes
//     if (s.startsWith('vm-') ||
//         s.startsWith('ad-') ||
//         s.startsWith('tx-') ||
//         s.startsWith('ax-') ||
//         s.contains('bank') ||
//         s.contains('hdfc') ||
//         s.contains('icici') ||
//         s.contains('sbi')) {
//       return SmsCategory.transactions;
//     }

//     // --- Second priority: Promotions ---
//     if (b.contains('offer') ||
//         b.contains('sale') ||
//         b.contains('discount') ||
//         b.contains('cashback') ||
//         b.contains('expires soon') ||
//         b.contains('buy 1 get 1') ||
//         b.contains('use code') ||
//         b.contains('flat off') ||
//         b.contains('limited time')) {
//       return SmsCategory.promotions;
//     }

//     // --- Third priority: Personal ---
//     // Check if sender is a phone number (e.g., +911234567890 or 1234567890)
//     // This RegExp checks for 10-15 digits, optionally starting with a '+'
//     if (RegExp(r'^\+?[0-9]{10,15}$').hasMatch(sender)) {
//       // Check for common "spammy" content from numbers
//       if (b.contains('lottery') ||
//           b.contains('win cash') ||
//           b.contains('click this link')) {
//         return SmsCategory
//             .promotions; // Or even a specific "spam" category if you add it
//       }
//       return SmsCategory.personal;
//     }

//     // If it's not a transaction and not from a number, it's likely a promotion or other service
//     if (b.contains('sale') || b.contains('discount')) {
//       return SmsCategory.promotions;
//     }

//     return SmsCategory.other;
//   }

//   /// Extracts a specific transaction type.
//   static TransactionType getTransactionType(String sender, String smsBody) {
//     String s = sender.toLowerCase();
//     String b = smsBody.toLowerCase();

//     // --- Priority 1: OTP ---
//     if (b.contains('otp') ||
//         b.contains('one-time password') ||
//         b.contains('verification code') ||
//         b.contains('security code') ||
//         b.contains('v-code')) {
//       return TransactionType.otp;
//     }

//     // --- Priority 2: Spam ---
//     if (b.contains('win') ||
//         b.contains('lottery') ||
//         b.contains('spam') ||
//         b.contains('claim reward') ||
//         b.contains('dear user you have won') ||
//         b.contains('click this link to win')) {
//       return TransactionType.spam;
//     }

//     // --- Priority 3: Alerts ---
//     if (b.contains('suspicious activity') ||
//         b.contains('login attempt') ||
//         b.contains('password reset') ||
//         b.contains('unauthorized transaction') ||
//         b.contains('service alert') ||
//         b.contains('important notice')) {
//       return TransactionType.alert;
//     }

//     // --- Priority 4: Orders ---
//     if (s.contains('amazon') ||
//         s.contains('flipkart') ||
//         b.contains('order') ||
//         s.contains('swiggy') ||
//         s.contains('zomato') ||
//         s.contains('meesho') ||
//         s.contains('myntra') ||
//         s.contains('zepto') ||
//         b.contains('shipped') ||
//         b.contains('delivered') ||
//         b.contains('out for delivery') ||
//         b.contains('order no.') ||
//         b.contains('awb')) {
//       return TransactionType.order;
//     }

//     // --- Priority 5: Travel ---
//     if (s.contains('indigo') ||
//         s.contains('airline') ||
//         b.contains('flight') ||
//         s.contains('ola') ||
//         s.contains('uber') ||
//         s.contains('rapido') ||
//         s.contains('makemytrip') ||
//         s.contains('goibibo') ||
//         b.contains('pnr') ||
//         b.contains('flight no.') ||
//         b.contains('booking id') ||
//         b.contains('check-in')) {
//       return TransactionType.travel;
//     }

//     // --- Priority 6: Bank ---
//     if (s.contains('bank') ||
//         s.contains('hdfc') ||
//         s.contains('icici') ||
//         s.contains('sbi') ||
//         s.contains('axis') ||
//         s.contains('kotak') ||
//         b.contains('a/c') ||
//         b.contains('acct') ||
//         b.contains('debited') ||
//         b.contains('credited') ||
//         b.contains('balance') ||
//         b.contains('txn') ||
//         b.contains('credit card') ||
//         b.contains('debit card')) {
//       return TransactionType.bank;
//     }

//     // --- Priority 7: Bill ---
//     if (s.contains('airtel') ||
//         s.contains('jio') ||
//         s.contains('vodafone') ||
//         s.contains('bses') ||
//         s.contains('igl') ||
//         b.contains('bill') ||
//         b.contains('due date') ||
//         b.contains('recharge') ||
//         b.contains('electricity bill') ||
//         b.contains('gas bill') ||
//         b.contains('pay by')) {
//       return TransactionType.bill;
//     }

//     // --- Priority 8: Social Media ---
//     if (s.contains('facebook') ||
//         s.contains('twitter') ||
//         s.contains('linkedin') ||
//         s.contains('instagram') ||
//         b.contains('is your facebook code') ||
//         b.contains('liked your post')) {
//       return TransactionType.social;
//     }

//     // --- Priority 9: Offers (if not caught by promotion category) ---
//     if (b.contains('offer') ||
//         b.contains('sale') ||
//         b.contains('discount') ||
//         b.contains('cashback')) {
//       return TransactionType.offer;
//     }

//     return TransactionType.none;
//   }

//   /// Calculates a Carbon Footprint score (e.g., higher for paperless bills).
//   /// Stub logic: Score (0-100) based on number of e-bills.
//   // --- FIX: Changed List<dynamic> to List<SmsMessage> ---
//   static double calculateCarbonFootprint(List<SmsMessage> messages) {
//     if (messages.isEmpty) return 0.0;
//     // Assume each e-bill contributes 5 points, max 100
//     double score =
//         messages
//             .where((m) => m.transactionType == TransactionType.bill)
//             .length *
//         5.0;
//     return score.clamp(0.0, 100.0); // Clamp score between 0 and 100
//   }

//   /// Calculates a User Trust Score.
//   /// Stub logic: Score (0-100) based on percentage of non-spam messages.
//   // --- FIX: Changed List<dynamic> to List<SmsMessage> ---
//   static double calculateTrustScore(List<SmsMessage> messages) {
//     if (messages.isEmpty) return 50.0; // Default score if no messages

//     int spamCount = messages
//         .where(
//           (m) =>
//               m.transactionType == TransactionType.spam ||
//               m.sentiment == Sentiment.spammy,
//         )
//         .length;

//     double score = ((messages.length - spamCount) / messages.length) * 100.0;
//     return score.clamp(0.0, 100.0);
//   }

//   /// Calculates a Privacy Insight Meter (PIM) score.
//   /// Stub logic: Score (0-1A00) as a risk meter. More sensitive messages (bank, OTP) = higher risk score.
//   // --- FIX: Changed List<dynamic> to List<SmsMessage> ---
//   static double calculatePIM(List<SmsMessage> messages) {
//     if (messages.isEmpty) return 0.0;

//     // Weight sensitive messages
//     int bankCount = messages
//         .where((m) => m.transactionType == TransactionType.bank)
//         .length;
//     int otpCount = messages
//         .where((m) => m.transactionType == TransactionType.otp)
//         .length;

//     // Give more weight to OTPs as they are higher risk
//     double riskScore =
//         ((bankCount * 1.0) + (otpCount * 2.0)) / messages.length * 100.0;

//     return riskScore.clamp(0.0, 100.0); // Higher score = higher privacy risk
//   }
// }




// 🗂 File: core/algorithms.dart

// --- FIX: Remove this import. It causes a circular dependency. ---
// 'sample_sms_data.dart' imports this file for enums.
// This file should not import 'sample_sms_data.dart'.
// import '/data/sample_sms_data.dart'; // <-- REMOVE THIS LINE

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
  delivery,
  eBill,
  subscription,
  creditCard
}

// --- 2. A HELPER CLASS TO HOLD THE ANALYSIS RESULT ---
class AnalysisResult {
  final SmsCategory category;
  final Sentiment sentiment;
  final TransactionType transactionType;

  AnalysisResult({
    required this.category,
    required this.sentiment,
    required this.transactionType,
  });
}

class WellnessSummary {
  final double ecoScore;
  final int papersSaved;

  WellnessSummary({this.ecoScore = 50.0, this.papersSaved = 0});
}


class PrivacySummary {
  final double pimScore; // Privacy Insight Meter (0-100, higher is riskier)
  final double trustScore; // Message Trust Score (0-100, higher is better)

  PrivacySummary({this.pimScore = 0.0, this.trustScore = 100.0});
}


// --- NEW: FinancialAccount Class ---
class FinancialAccount {
  final String id; // Unique ID (e.g., "HDFCBK-1234")
  final String name; // e.g., "HDFC Bank"
  final String number; // e.g., "xx...1234"
  final double balance; // e.g., 55000.00
  final DateTime lastUpdated;
  final TransactionType type; // bank or creditCard

  FinancialAccount({
    required this.id,
    required this.name,
    required this.number,
    required this.balance,
    required this.lastUpdated,
    required this.type,
  });
}

class SmsAnalyzer {
  //
  // --- THIS IS THE FIX ---
  // The 'analyze' function is now a public method of SmsAnalyzer,
  // NOT nested inside analyzeSentiment.
  //
  AnalysisResult analyze(String body) {
    String lowerBody = body.toLowerCase();

// Rule: Spam
    if (lowerBody.contains('congratulations') ||
        lowerBody.contains('you have won') ||
        lowerBody.contains('lottery') ||
        lowerBody.contains('claim now') ||
        lowerBody.contains('click this link')) {
      return AnalysisResult(
        category: SmsCategory.promotions,
        sentiment: Sentiment.spammy,
        transactionType: TransactionType.spam,
      );
    }


// --- NEW: Subscription Rule ---
    if (lowerBody.contains('unsubscribe') ||
        lowerBody.contains('pre-approvedt') ||
        lowerBody.contains('no longer wish to receive')) {
      return AnalysisResult(
        category: SmsCategory.promotions,
        sentiment: Sentiment.neutral,
        transactionType: TransactionType.subscription,
      );
    }    

    // Rule 1: OTP
    if (lowerBody.contains('otp') ||
        lowerBody.contains('verification code') ||
        (lowerBody.contains('code is') && lowerBody.length < 100)) {
      return AnalysisResult(
        category: SmsCategory.transactions,
        sentiment: Sentiment.neutral,
        transactionType: TransactionType.otp,
      );
    }

// Rule: Bank vs. Credit Card
    if (lowerBody.contains('credit card') || lowerBody.contains(' cc ')) {
      return AnalysisResult(
        category: SmsCategory.transactions,
        sentiment: Sentiment.neutral,
        transactionType: TransactionType.creditCard,
      );
    }
    if (lowerBody.contains('a/c') ||
        lowerBody.contains('account') ||
        lowerBody.contains('bank')) {
      return AnalysisResult(
        category: SmsCategory.transactions,
        sentiment: Sentiment.neutral,
        transactionType: TransactionType.bank,
      );
    }    

    // Rule 2: Order / Shipping
    if (lowerBody.contains('order') ||
        lowerBody.contains('shipped') ||
        lowerBody.contains('delivered') ||
        lowerBody.contains('out for delivery')) {
      return AnalysisResult(
        category: SmsCategory.transactions,
        sentiment: Sentiment.happy,
        transactionType: TransactionType.order,
      );
    }

    // Rule 3: Offers
    if (lowerBody.contains('offer') ||
        lowerBody.contains('discount') ||
        lowerBody.contains('% off') ||
        lowerBody.contains('sale')) {
      return AnalysisResult(
        category: SmsCategory.promotions,
        sentiment: Sentiment.neutral,
        transactionType: TransactionType.offer,
      );
    }

    // Rule 4: Spam
    if (lowerBody.contains('congratulations') ||
        lowerBody.contains('you have won') ||
        lowerBody.contains('lottery') ||
        lowerBody.contains('click here')) {
      return AnalysisResult(
        category: SmsCategory.promotions,
        sentiment: Sentiment.warning,
        transactionType: TransactionType.spam,
      );
    }

    // Rule 5: Bank Transactions
    if (lowerBody.contains('debited') ||
        lowerBody.contains('credited') ||
        lowerBody.contains('a/c') ||
        lowerBody.contains('rs.') ||
        lowerBody.contains('balance is')) {
      Sentiment sentiment = Sentiment.neutral;
      if (lowerBody.contains('low balance')) sentiment = Sentiment.warning;
      if (lowerBody.contains('credited')) sentiment = Sentiment.happy;

      return AnalysisResult(
        category: SmsCategory.transactions,
        sentiment: sentiment,
        transactionType: TransactionType.bank,
      );
    }

    if (lowerBody.contains('delivery') ||
          lowerBody.contains('out for delivery') ||
          lowerBody.contains('arriving today')) {
        return AnalysisResult(
          category: SmsCategory.transactions,
          sentiment: Sentiment.happy,
          transactionType: TransactionType.delivery,
        );
      }  

    if (lowerBody.contains('e-bill') ||
        lowerBody.contains('e-statement') ||
        lowerBody.contains('download your bill') ||
        lowerBody.contains('.pdf')) {
      return AnalysisResult(
        category: SmsCategory.transactions,
        sentiment: Sentiment.neutral,
        transactionType: TransactionType.eBill,
      );
    }        
    // --- Default: Personal ---
    // If no other rules match, assume it's personal
    return AnalysisResult(
      category: SmsCategory.personal,
      sentiment: Sentiment.neutral,
      transactionType: TransactionType.none,
    );
  }
  // --- END OF FIX ---

  /// Analyzes the SMS body for its emotional tone.
  static Sentiment analyzeSentiment(String smsBody) {
    String body = smsBody.toLowerCase();

    // The 'analyze' function was incorrectly here. It has been moved.

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

static WellnessSummary calculateWellnessSummary(List<SmsMessage> messages) {
    if (messages.isEmpty) return WellnessSummary();

    int eBillCount = 0;
    int spamCount = 0;

    for (var msg in messages) {
      if (msg.transactionType == TransactionType.eBill) {
        eBillCount++;
      } else if (msg.category == SmsCategory.promotions) {
        spamCount++;
      }
    }

    // Logic: Start at 50. +5 for every e-bill. -0.1 for every promo.
    double score = 50.0 + (eBillCount * 5) - (spamCount * 0.1);

    return WellnessSummary(
      ecoScore: score.clamp(0.0, 100.0), // Ensure score is between 0 and 100
      papersSaved: eBillCount, // 1 e-bill = 1 paper saved
    );
  }  

  /// Calculates PIM and Trust Score
  static PrivacySummary calculatePrivacySummary(List<SmsMessage> messages) {
    if (messages.isEmpty) return PrivacySummary();

    int totalMessages = messages.length;
    int spamCount = 0;
    int pimRiskPoints = 0;

    for (var msg in messages) {
      if (msg.transactionType == TransactionType.spam) {
        spamCount++;
      }
      // PIM: Give "risk points" for messages containing sensitive data
      if (msg.transactionType == TransactionType.otp) {
        pimRiskPoints += 3; // High risk
      }
      if (msg.transactionType == TransactionType.bank) {
        pimRiskPoints += 1; // Medium risk
      }
      if (msg.body.toLowerCase().contains('password')) {
        pimRiskPoints += 5; // Very high risk
      }
    }

    // Trust Score: 0-100, (non-spam / total)
    double trustScore = ((totalMessages - spamCount) / totalMessages) * 100.0;

    // PIM Score: 0-100, (risk points / total)
    // This is a "risk" score. A higher number is WORSE.
    double pimScore = (pimRiskPoints / totalMessages) * 100.0;

    return PrivacySummary(
      trustScore: trustScore.clamp(0.0, 100.0),
      pimScore: pimScore.clamp(0.0, 100.0), // Higher = Riskier
    );
  }


/// Parses all SMS messages and returns a list of unique accounts
  static Map<String, List<FinancialAccount>> parseFinancialAccounts(
    List<SmsMessage> messages,
  ) {
    final Map<String, FinancialAccount> latestAccounts = {};

    // Filter for messages that are bank or credit card
    var financialMessages = messages.where(
      (m) =>
          m.transactionType == TransactionType.bank ||
          m.transactionType == TransactionType.creditCard,
    );

    for (var msg in financialMessages) {
      String? accNumber = _extractAccountNumber(msg.body);
      double? balance = _extractBalance(msg.body);

      // We need an account number and a balance to proceed
      if (accNumber == null || balance == null) continue;

      String id = "${msg.sender}-$accNumber";
      String name = msg.sender.replaceAll(
        RegExp(r'^[A-Z]{2}-'),
        '',
      ); // Clean up "VM-HDFCBK" to "HDFCBK"

      // Check if this account is already in our map
      if (!latestAccounts.containsKey(id) ||
          msg.timestamp.isAfter(latestAccounts[id]!.lastUpdated)) {
        // If it's new, or if this message is *newer* than the one we have, update it.
        latestAccounts[id] = FinancialAccount(
          id: id,
          name: name,
          number: accNumber,
          balance: balance,
          lastUpdated: msg.timestamp,
          type: msg.transactionType,
        );
      }
    }

    // Now, split the map into two lists
    List<FinancialAccount> bankAccounts = [];
    List<FinancialAccount> creditCards = [];

    for (var account in latestAccounts.values) {
      if (account.type == TransactionType.bank) {
        bankAccounts.add(account);
      } else {
        creditCards.add(account);
      }
    }

    return {'accounts': bankAccounts, 'cards': creditCards};
  }

  /// Helper to extract account number (e.g., xx...1234)
  static String? _extractAccountNumber(String body) {
    // Looks for "a/c", "acct", "card", "cc" followed by "xx" or "..." and 4 digits
    final match = RegExp(
      r'(a/c|acct|card|cc).*(xx|\.+)(\d{4})',
      caseSensitive: false,
    ).firstMatch(body);

    if (match != null) {
      // Return the "xx...1234" part
      return "xx...${match.group(3)}";
    }
    return null;
  }

  /// Helper to extract balance (e.g., Rs. 55,000.00)
  static double? _extractBalance(String body) {
    // Looks for "avbl bal", "balance is", "bal:", etc.
    final match = RegExp(
      r'(avbl bal|balance is|bal:|balance:).*(rs\.?|inr)\s*([\d,]+\.?\d*)',
      caseSensitive: false,
    ).firstMatch(body);

    if (match != null && match.group(3) != null) {
      try {
        // Remove commas and parse
        return double.parse(match.group(3)!.replaceAll(',', ''));
      } catch (e) {
        return null;
      }
    }

    // --- Fallback for Credit Cards ---
    // Looks for "total due: Rs. 5,000"
    final dueMatch = RegExp(
      r'(total (?:amount )?due:).*(rs\.?|inr)\s*([\d,]+\.?\d*)',
      caseSensitive: false,
    ).firstMatch(body);

    if (dueMatch != null && dueMatch.group(3) != null) {
      try {
        return double.parse(dueMatch.group(3)!.replaceAll(',', ''));
      } catch (e) {
        return null;
      }
    }

    return null;
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

  // --- FIX for circular dependency ---
  // These static methods should not depend on the 'SmsMessage' class
  // from 'sample_sms_data.dart'.
  // We can't fix this without knowing where your 'SmsMessage' class
  // is defined. For now, I will comment them out to fix your
  // immediate error.
 /*
  /// Calculates a Carbon Footprint score (e.g., higher for paperless bills).
  /// Stub logic: Score (0-100) based on number of e-bills.
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
 */
}
