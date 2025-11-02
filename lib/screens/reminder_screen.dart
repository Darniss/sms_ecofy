import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/core/algorithms.dart' as alogo_;
import '/data/sample_sms_data.dart';
import '/providers/reminder_provider.dart'; // <-- IMPORT PROVIDER
import '/screens/chat_screen.dart';
import '/utils/theme.dart';

// --- The _ReminderInfo class is now in the provider file ---

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  // --- State Variables ---
  int _selectedTab = 0; // 0: All Reminders, 1: History

  // --- 7. The Main UI Build Method ---
  @override
  Widget build(BuildContext context) {
    // --- NEW: Get the provider ---
    final reminderProvider = context.watch<ReminderProvider>();

    // Decide which list to show
    final List<ReminderInfo> filteredReminders = _selectedTab == 0
        ? reminderProvider.upcomingReminders
        : reminderProvider.historyReminders;

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders'), centerTitle: true),
      body: Column(
        children: [
          _buildToggleChips(),
          Expanded(
            child: reminderProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildReminderListView(
                    filteredReminders,
                    reminderProvider.allMessages,
                  ),
          ),
        ],
      ),
    );
  }

  // --- 8. The "Joined Chips" UI ---
  Widget _buildToggleChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ToggleButtons(
        isSelected: [_selectedTab == 0, _selectedTab == 1],
        onPressed: (index) {
          setState(() {
            _selectedTab = index;
            // No need to call _filterList, the Consumer will rebuild!
          });
        },
        borderRadius: BorderRadius.circular(20.0),
        selectedColor: Colors.white,
        fillColor: kEcoGreen,
        color: kEcoGreen,
        constraints: BoxConstraints(
          minWidth: (MediaQuery.of(context).size.width - 40) / 2,
          minHeight: 40.0,
        ),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('All Reminders'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('History'),
          ),
        ],
      ),
    );
  }

  // --- 9. The List View UI ---
  Widget _buildReminderListView(
    List<ReminderInfo> filteredReminders,
    List<SmsMessage> allMessages,
  ) {
    if (filteredReminders.isEmpty) {
      return Center(
        child: Text(
          _selectedTab == 0 ? 'No upcoming reminders' : 'No reminder history',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredReminders.length,
      itemBuilder: (context, index) {
        final reminder = filteredReminders[index];
        final message = reminder.message;

        IconData icon = Icons.notifications;
        if (message.transactionType == alogo_.TransactionType.bill) {
          icon = Icons.receipt_long;
        } else if (message.transactionType == alogo_.TransactionType.travel) {
          icon = Icons.flight_takeoff;
        } else if (message.transactionType == alogo_.TransactionType.delivery) {
          icon = Icons.local_shipping;
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: kEcoGreen.withOpacity(0.1),
            child: Icon(icon, color: kEcoGreen),
          ),
          title: Text(
            message.sender,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            message.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            DateFormat('MMM d').format(reminder.eventDate), // "Nov 5"
            style: const TextStyle(color: Colors.grey),
          ),
          onTap: () {
            // --- 10. Navigation to ChatScreen with Blink ---
            // 1. Get all messages for this thread/sender
            List<SmsMessage> threadMessages = allMessages
                .where((m) => m.sender == message.sender)
                .toList();

            // 2. Sort them by time, OLDEST to NEWEST
            threadMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

            // 3. Navigate, passing the ID of the message to highlight
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  sender: message.sender,
                  messages: threadMessages,
                  messageToHighlightId: message.id, // <-- Pass the ID
                ),
              ),
            );
          },
        );
      },
    );
  }
}
