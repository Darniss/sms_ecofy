// 𗗂 File: screens/spam_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/providers/reminder_provider.dart';
import '/data/sample_sms_data.dart';
import '/screens/chat_screen.dart';

class SpamListScreen extends StatelessWidget {
  const SpamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We don't need 'watch' because the list won't change while we're on this screen
    final provider = context.read<ReminderProvider>();
    final spamMessages = provider.spamMessages;
    final allMessages = provider.allMessages;

    return Scaffold(
      appBar: AppBar(title: const Text('Spam Reports')),
      body: spamMessages.isEmpty
          ? const Center(
              child: Text(
                'No spam messages found!',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: spamMessages.length,
              itemBuilder: (context, index) {
                final message = spamMessages[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.shield_outlined),
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
                  trailing: Text(DateFormat.MMMd().format(message.timestamp)),
                  onTap: () {
                    // Navigate to chat with blink
                    List<SmsMessage> thread = allMessages
                        .where((m) => m.sender == message.sender)
                        .toList();
                    thread.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          sender: message.sender,
                          messages: thread,
                          messageToHighlightId: message.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
