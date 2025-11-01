import 'package:intl/intl.dart';
import '/data/sample_sms_data.dart'; 

class TimeHelper {
  // Use a fixed date for reliable testing.
  static final _now = DateTime(2025, 11, 1); // This is a Saturday
  // static final _now = DateTime.now(); // Use this in production

  // --- Chip Generators ---

  static List<String> generateDayChips() {
    // --- UPDATED: Changed format to include day of the week ---
    final format = DateFormat('E, MMM d'); // e.g., "Sat, Nov 1"
    return List.generate(
      7,
      (i) => format.format(_now.subtract(Duration(days: i))),
    );
  }

  static List<String> generateWeekChips() {
    // (This is unchanged)
    return List.generate(4, (i) {
      final weekDate = _now.subtract(Duration(days: i * 7));
      final weekNumber = _getWeekOfYear(weekDate);
      return 'Week $weekNumber';
    });
  }

  static List<String> generateMonthChips() {
    // (This is unchanged)
    return List.generate(6, (i) {
      final monthDate = DateTime(_now.year, _now.month - i, 1);
      return DateFormat('MMMM').format(monthDate);
    });
  }

  // --- Filtering Logic ---

  static List<SmsMessage> filterMessagesByTime(
    List<SmsMessage> messages,
    String timelineFilter,
    String selectedChip,
  ) {
    if (timelineFilter == 'All') {
      return messages;
    }

    return messages.where((msg) {
      switch (timelineFilter) {
        case 'Day':
          // --- UPDATED: Use the new format to parse the chip text ---
          final chipDate = DateFormat('E, MMM d').parse(selectedChip);
          final chipDay = chipDate.day;
          final chipMonth = chipDate.month;
          return msg.timestamp.day == chipDay &&
              msg.timestamp.month == chipMonth;
        case 'Weekly':
          // (Unchanged)
          final weekNum = int.tryParse(selectedChip.split(' ').last) ?? 0;
          final msgWeekNum = _getWeekOfYear(msg.timestamp);
          return msgWeekNum == weekNum;
        case 'Monthly':
          // (Unchanged)
          final chipMonth = DateFormat('MMMM').parse(selectedChip).month;
          return msg.timestamp.month == chipMonth;
        default:
          return true;
      }
    }).toList();
  }

  // --- Utility ---
  static int _getWeekOfYear(DateTime date) {
    // (This is unchanged)
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (weekNumber == 0) {
      return _getWeekOfYear(date.subtract(const Duration(days: 7)));
    }
    return weekNumber;
  }
}
