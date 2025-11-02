import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/data/sample_sms_data.dart'; // For SmsMessage
import '/widgets/chat_bubble_widget.dart'; // You will create this

class ChatScreen extends StatefulWidget {
  final String sender;
  final List<SmsMessage> messages;

  const ChatScreen({super.key, required this.sender, required this.messages});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isSelectionMode = false;
  final Set<SmsMessage> _selectedMessages = {};

  // --- Permission & Call Logic ---
  Future<void> _makeCall() async {
    // This is a major assumption: that the sender is a phone number.
    // This will FAIL for "HDFC Bank". You need logic to find a
    // phone number associated with the contact.
    if (!widget.sender.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot call sender: ${widget.sender}")),
      );
      return;
    }

    final Uri callUri = Uri(scheme: 'tel', path: widget.sender);

    // You should check for Permission.phone here, as you requested.
    // This requires permission_handler package
    // var status = await Permission.phone.request();
    // if (status.isGranted) {
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      // Show error
    }
    // } else {
    //   // Show "permission denied" dialog
    // }
  }

  // --- Build Methods ---
  AppBar _buildDefaultAppBar() {
    return AppBar(
      title: Text(widget.sender),
      actions: [
        IconButton(icon: const Icon(Icons.phone), onPressed: _makeCall),
        PopupMenuButton(
          itemBuilder: (context) => [
            // Your 3-dot menu options
          ],
        ),
      ],
    );
  }

  AppBar _buildSelectionAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _isSelectionMode = false;
            _selectedMessages.clear();
          });
        },
      ),
      title: Text('${_selectedMessages.length} selected'),
      actions: [
        // Add Select All, Delete, Copy, etc.
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelectionMode
          ? _buildSelectionAppBar()
          : _buildDefaultAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Shows chat from the bottom
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final message = widget.messages[index];
                final isSelected = _selectedMessages.contains(message);

                // You'd also add logic here to show a Date Separator

                return ChatBubbleWidget(
                  message: message,
                  isSelected: isSelected,
                  onTap: () {
                    if (_isSelectionMode) {
                      setState(() {
                        if (isSelected) {
                          _selectedMessages.remove(message);
                        } else {
                          _selectedMessages.add(message);
                        }
                        if (_selectedMessages.isEmpty) {
                          _isSelectionMode = false;
                        }
                      });
                    }
                  },
                  onLongPress: () {
                    if (!_isSelectionMode) {
                      setState(() {
                        _isSelectionMode = true;
                        _selectedMessages.add(message);
                      });
                    }
                  },
                );
              },
            ),
          ),
          // Add your message reply box here
        ],
      ),
    );
  }
}
