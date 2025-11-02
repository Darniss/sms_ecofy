import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/data/sample_sms_data.dart'; // For SmsMessage
import '/utils/theme.dart'; // For kEcoGreen

class ChatBubbleWidget extends StatelessWidget {
  final SmsMessage message;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // In a real app, you would check if the message 'type' is SENT or RECEIVED.
    // Since your model doesn't have this, we'll assume all are RECEIVED.
    const bool isReceived = true;

    final align = isReceived ? Alignment.centerLeft : Alignment.centerRight;
    final bubbleColor = isReceived
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : kEcoGreen.withOpacity(0.8);
    final textColor = isReceived
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : Colors.white;

    final bubbleRadius = isReceived
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: isSelected ? kEcoGreen.withOpacity(0.2) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Align(
          alignment: align,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: bubbleRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.body,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('h:mm a').format(message.timestamp),
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}