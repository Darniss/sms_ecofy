import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // <-- Add this package

import '/providers/reminder_provider.dart';
import '/data/sample_sms_data.dart';
import '/screens/chat_screen.dart';

class SubscriptionManagerScreen extends StatelessWidget {
  const SubscriptionManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ReminderProvider>();
    final subscriptions = provider.subscriptionMessages;
    final allMessages = provider.allMessages;

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Hub')),
      body: subscriptions.isEmpty
          ? const Center(
              child: Text(
                'No subscriptions found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final message = subscriptions[index];
                return Slidable(
                  key: Key(message.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          // TODO: Implement block logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Blocked ${message.sender}'),
                            ),
                          );
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.block,
                        label: 'Block',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.unsubscribe)),
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
                  ),
                );
              },
            ),
    );
  }
}
