import '/core/algorithms.dart';
import '/utils/time_helper.dart';
import 'package:flutter/material.dart';
import '/data/sample_sms_data.dart'; // For SmsMessage
import '/widgets/summary_cards_section.dart'; // For SummaryCardData

class SummaryDetailScreen extends StatefulWidget {
  final SummaryCardData card;
  const SummaryDetailScreen({super.key, required this.card});

  @override
  State<SummaryDetailScreen> createState() => _SummaryDetailScreenState();
}

class _SummaryDetailScreenState extends State<SummaryDetailScreen> {
  List<SmsMessage> _filteredMessages = [];
  final String _layoutType = 'list'; // Default layout

  @override
  void initState() {
    super.initState();
    _loadAndFilterMessages();
  }

  void _loadAndFilterMessages() {
    // In a real app, you'd get this from your SmsProvider
    List<SmsMessage> allMessages = sampleSmsList;

    // This is a simple filter. You'll need to make this logic more robust.
    // E.g., 'orders' maps to 'TransactionType.order'
    // 'pim', 'carbon', 'trust' don't map to messages and should be handled.
    String categoryName = widget.card.title.toLowerCase();

    setState(() {
      _filteredMessages = allMessages.where((msg) {
        if (categoryName == 'offers') {
          return msg.transactionType == TransactionType.offer;
        }
        if (categoryName == 'orders') {
          return msg.transactionType == TransactionType.order;
        }
        if (categoryName == 'travel') {
          return msg.transactionType == TransactionType.travel;
        }
        // Add all other filter logic here...
        return msg.category.name.toLowerCase() == categoryName;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              // NEW: Matching Hero tag
              tag: 'summary_icon_${widget.card.id}',
              child: Icon(widget.card.icon, color: widget.card.color, size: 24),
            ),
            const SizedBox(width: 8),
            Text(widget.card.title),
          ],
        ),
        actions: [
          // Add grid/list toggle buttons here
        ],
      ),
      body: _filteredMessages.isEmpty
          ? const Center(child: Text('No messages found.'))
          : _buildMessageList(), // Implement _buildMessageList (grid or list)
    );
  }

  Widget _buildMessageList() {
    // Build your ListView or GridView here
    return ListView.builder(
      itemCount: _filteredMessages.length,
      itemBuilder: (context, index) {
        final message = _filteredMessages[index];
        return ListTile(
          title: Text(message.sender),
          subtitle: Text(message.body, maxLines: 1),
          trailing: Text(
            TimeHelper.formatTimestamp(message.timestamp),
          ), // You'll need a TimeHelper
          onTap: () {
            // NEXT STEP: Navigate to ChatScreen
            // Navigator.of(context).push(MaterialPageRoute(
            //   builder: (context) => ChatScreen(sender: message.sender),
            // ));
          },
        );
      },
    );
  }
}
