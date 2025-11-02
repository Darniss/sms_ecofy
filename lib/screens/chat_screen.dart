// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '/data/sample_sms_data.dart'; // For SmsMessage
// import '/widgets/chat_bubble_widget.dart'; // You will create this

// class ChatScreen extends StatefulWidget {
//   final String sender;
//   final List<SmsMessage> messages;

//   const ChatScreen({super.key, required this.sender, required this.messages});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   bool _isSelectionMode = false;
//   Set<SmsMessage> _selectedMessages = {};

//   // --- Permission & Call Logic ---
//   Future<void> _makeCall() async {
//     // This is a major assumption: that the sender is a phone number.
//     // This will FAIL for "HDFC Bank". You need logic to find a
//     // phone number associated with the contact.
//     if (!widget.sender.startsWith('+')) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Cannot call sender: ${widget.sender}")),
//       );
//       return;
//     }

//     final Uri callUri = Uri(scheme: 'tel', path: widget.sender);

//     // You should check for Permission.phone here, as you requested.
//     // This requires permission_handler package
//     // var status = await Permission.phone.request();
//     // if (status.isGranted) {
//     if (await canLaunchUrl(callUri)) {
//       await launchUrl(callUri);
//     } else {
//       // Show error
//     }
//     // } else {
//     //   // Show "permission denied" dialog
//     // }
//   }

//   // --- Build Methods ---
//   AppBar _buildDefaultAppBar() {
//     return AppBar(
//       title: Text(widget.sender),
//       actions: [
//         IconButton(icon: const Icon(Icons.phone), onPressed: _makeCall),
//         PopupMenuButton(
//           itemBuilder: (context) => [
//             // Your 3-dot menu options
//           ],
//         ),
//       ],
//     );
//   }

//   AppBar _buildSelectionAppBar() {
//     return AppBar(
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back),
//         onPressed: () {
//           setState(() {
//             _isSelectionMode = false;
//             _selectedMessages.clear();
//           });
//         },
//       ),
//       title: Text('${_selectedMessages.length} selected'),
//       actions: [
//         // Add Select All, Delete, Copy, etc.
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _isSelectionMode
//           ? _buildSelectionAppBar()
//           : _buildDefaultAppBar(),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               reverse: true, // Shows chat from the bottom
//               itemCount: widget.messages.length,
//               itemBuilder: (context, index) {
//                 final message = widget.messages[index];
//                 final isSelected = _selectedMessages.contains(message);

//                 // You'd also add logic here to show a Date Separator

//                 return ChatBubbleWidget(
//                   message: message,
//                   isSelected: isSelected,
//                   onTap: () {
//                     if (_isSelectionMode) {
//                       setState(() {
//                         if (isSelected) {
//                           _selectedMessages.remove(message);
//                         } else {
//                           _selectedMessages.add(message);
//                         }
//                         if (_selectedMessages.isEmpty) {
//                           _isSelectionMode = false;
//                         }
//                       });
//                     }
//                   },
//                   onLongPress: () {
//                     if (!_isSelectionMode) {
//                       setState(() {
//                         _isSelectionMode = true;
//                         _selectedMessages.add(message);
//                       });
//                     }
//                   },
//                 );
//               },
//             ),
//           ),
//           // Add your message reply box here
//         ],
//       ),
//     );
//   }
// }



// 🗂 File: screens/chat_screen.dart
// (This is the new, fully-featured chat screen)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// Import your other files
import '/data/sample_sms_data.dart';
import '/core/algorithms.dart';
import '/widgets/chat_bubble_widget.dart';
import '/utils/storage_service.dart';
import '/services/sms_service.dart'; // You will need this
import '/config/env_config.dart';
import '/utils/theme.dart';

class ChatScreen extends StatefulWidget {
  final String sender;
  final List<SmsMessage> messages;

  const ChatScreen({super.key, required this.sender, required this.messages});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // --- State Variables ---
  late List<SmsMessage> _messages; // A mutable copy of the messages
  bool _isSelectionMode = false;
  final Set<String> _selectedMessageIds = {};

  // For reply bar
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _canSend = false;

  // For thread state
  bool _isPinned = false;
  bool _isMuted = false;

  // Services
  final StorageService _storageService = StorageService();
  final SmsService _smsService = SmsService();

  // --- Init & Dispose ---
  @override
  void initState() {
    super.initState();
    // 1. Create a mutable copy of the message list
    _messages = List.from(widget.messages);

    // 2. Load thread state
    _loadThreadState();

    // 3. Listen to the reply controller
    _replyController.addListener(() {
      setState(() {
        _canSend = _replyController.text.isNotEmpty;
      });
    });

    // 4. Scroll to the bottom after the UI builds
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _jumpToBottom(animated: false),
    );
  }

  Future<void> _loadThreadState() async {
    final isPinned = await _storageService.isThreadPinned(widget.sender);
    final isMuted = await _storageService.isSenderMuted(widget.sender);
    if (mounted) {
      setState(() {
        _isPinned = isPinned;
        _isMuted = isMuted;
      });
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelectionMode
          ? _buildSelectionAppBar()
          : _buildDefaultAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildReplyBar(),
        ],
      ),
    );
  }

  // --- Default AppBar ---
  AppBar _buildDefaultAppBar() {
    return AppBar(
      title: Text(
        widget.sender,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.phone), onPressed: _makeCall),
        PopupMenuButton<String>(
          onSelected: _onDefaultMenuSelected,
          itemBuilder: (context) => [
            // Move to
            // Pin Chat
            PopupMenuItem(
              value: 'pin',
              child: Text(_isPinned ? 'Unpin Chat' : 'Pin Chat'),
            ),
            // Mute Sender
            PopupMenuItem(
              value: 'mute',
              child: Text(_isMuted ? 'Unmute Sender' : 'Mute Sender'),
            ),
            // Delete
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
            // View Contact
            const PopupMenuItem(value: 'contact', child: Text('View Contact')),
            // Quick Replies
            // Block Sender
            // Report Sender
          ],
        ),
      ],
    );
  }

  // --- Selection AppBar ---
  AppBar _buildSelectionAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _exitSelectionMode,
      ),
      title: Text('${_selectedMessageIds.length} selected'),
      actions: [
        IconButton(icon: const Icon(Icons.select_all), onPressed: _onSelectAll),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _onDeleteSelected,
        ),
        IconButton(icon: const Icon(Icons.copy), onPressed: _onCopySelected),
        PopupMenuButton<String>(
          onSelected: _onSelectionMenuSelected,
          itemBuilder: (context) => [
            // Share SMS
            const PopupMenuItem(value: 'share', child: Text('Share SMS')),
            // Move to
            // Add Reminder
            // Forward SMS
          ],
        ),
      ],
    );
  }

  // --- Message List (with Date Separator logic) ---
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        bool showSeparator = false;

        // --- Date Separator Logic ---
        if (index == 0) {
          showSeparator = true; // Always show for the very first message
        } else {
          final prevMessage = _messages[index - 1];
          // Check if the month, day, or year is different
          if (message.timestamp.day != prevMessage.timestamp.day ||
              message.timestamp.month != prevMessage.timestamp.month ||
              message.timestamp.year != prevMessage.timestamp.year) {
            showSeparator = true;
          }
        }

        return Column(
          children: [
            if (showSeparator) _buildDateSeparator(message.timestamp),
            ChatBubbleWidget(
              message: message,
              // We assume all loaded messages are "received" (isSent: false)
              // You'll need to update this if your model gets a "type" field
              isSent: false,
              isSelected: _selectedMessageIds.contains(message.id),
              onTap: () => _onMessageTap(message),
              onLongPress: () => _onMessageLongPress(message),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          DateFormat.yMMMMd().format(date), // e.g., "November 2, 2025"
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  // --- Reply Bar ---
  Widget _buildReplyBar() {
    return Container(
      padding: const EdgeInsets.all(8.0).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 8.0,
      ), // Handle notch
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // You can add an emoji/attachment button here
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                hintText: 'Send message...',
                border: InputBorder.none,
                filled: false,
              ),
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: _canSend ? kEcoGreen : Colors.grey),
            onPressed: _canSend ? _onSend : null,
          ),
        ],
      ),
    );
  }

  // --- Action Handlers (Default) ---

  void _onDefaultMenuSelected(String value) {
    switch (value) {
      case 'pin':
        _onPin();
        break;
      case 'mute':
        _onMute();
        break;
      case 'delete':
        _onDeleteThread();
        break;
      // Add other cases here
    }
  }

  Future<void> _makeCall() async {
    // This is a major assumption: that the sender is a phone number.
    // This will FAIL for "HDFC Bank". You need logic to find a
    // phone number associated with the contact.
    if (!widget.sender.startsWith('+') &&
        !RegExp(r'^[0-9]{10,}$').hasMatch(widget.sender)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot call sender: ${widget.sender}")),
      );
      return;
    }

    final Uri callUri = Uri(scheme: 'tel', path: widget.sender);
    // You must add <uses-permission android:name="android.permission.CALL_PHONE"/>
    // to your AndroidManifest.xml for this to work.
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not launch call")));
    }
  }

  void _onPin() {
    setState(() {
      _isPinned = !_isPinned;
    });
    _storageService.setThreadPinned(widget.sender, _isPinned);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isPinned ? 'Chat Pinned' : 'Chat Unpinned')),
    );
  }

  void _onMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _storageService.setSenderMuted(widget.sender, _isMuted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isMuted ? 'Sender Muted' : 'Sender Unmuted')),
    );
  }

  void _onDeleteThread() {
    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Thread?'),
        content: const Text(
          'Are you sure you want to permanently delete this conversation?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              // In a real app, you'd delete this from the
              // native SMS database.
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close chat screen
              // You'd also need to notify the home_screen to refresh
            },
          ),
        ],
      ),
    );
  }

  // --- Action Handlers (Selection) ---

  void _onSelectionMenuSelected(String value) {
    switch (value) {
      case 'share':
        _onShareSelected();
        break;
      // Add other cases
    }
  }

  void _onShareSelected() {
    // You need the 'share_plus' package for this
    // String shareText = _getSelectedMessagesBody();
    // Share.share(shareText);
    print('Share: ${_getSelectedMessagesBody()}');
  }

  void _onCopySelected() {
    String copyText = _getSelectedMessagesBody();
    Clipboard.setData(ClipboardData(text: copyText));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
    _exitSelectionMode();
  }

  void _onDeleteSelected() {
    // In a real app, this would delete from the native DB.
    // Here, we just remove from our local list.
    setState(() {
      _messages.removeWhere((msg) => _selectedMessageIds.contains(msg.id));
      _exitSelectionMode();
    });
  }

  void _onSelectAll() {
    setState(() {
      if (_selectedMessageIds.length == _messages.length) {
        // If all are selected, deselect all
        _selectedMessageIds.clear();
      } else {
        // Otherwise, select all
        _selectedMessageIds.addAll(_messages.map((m) => m.id));
      }
    });
  }

  // --- Action Handlers (Messaging) ---

  void _onSend() async {
    final body = _replyController.text;
    if (body.isEmpty) return;

    // --- Create a "fake" message for the UI instantly ---
    // This gives the user immediate feedback.
    final tempMessage = SmsMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'You', // This indicates it's a "sent" message
      body: body,
      timestamp: DateTime.now(),
      category: SmsCategory.personal, // Default category for sent
      sentiment: Sentiment.neutral,
      transactionType: TransactionType.none,
    );

    // --- Add to UI and scroll ---
    // We add to the *end* of the list (newest)
    setState(() {
      // THIS IS WHERE YOU WOULD USE isSent: true
      // But our ChatBubbleWidget doesn't support it yet.
      // Let's modify the list to add a "type"
      // For now, we just add it
      _messages.add(tempMessage);
    });
    _replyController.clear();
    _jumpToBottom(animated: true);

    // --- Send the real SMS ---
    // Note: 'widget.sender' might be "HDFC Bank".
    // This send will fail. This reply UI only works for real numbers.
    await _smsService.sendSms([widget.sender], body);

    // Once sent, you could update the `tempMessage` with a real ID
    // or status (e.g., 'Sent', 'Failed').
  }

  // --- Gesture Handlers ---

  void _onMessageTap(SmsMessage message) {
    if (_isSelectionMode) {
      // If in selection mode, toggle selection
      setState(() {
        if (_selectedMessageIds.contains(message.id)) {
          _selectedMessageIds.remove(message.id);
        } else {
          _selectedMessageIds.add(message.id);
        }
        // If no items are selected, exit selection mode
        if (_selectedMessageIds.isEmpty) {
          _exitSelectionMode();
        }
      });
    } else {
      // Default tap action (e.g., show timestamp, but we show it anyway)
    }
  }

  void _onMessageLongPress(SmsMessage message) {
    if (!_isSelectionMode) {
      // Enter selection mode and select this message
      setState(() {
        _isSelectionMode = true;
        _selectedMessageIds.add(message.id);
      });
    }
  }

  // --- Utility Methods ---

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedMessageIds.clear();
    });
  }

  String _getSelectedMessagesBody() {
    // Get all selected messages, sort them, and join them.
    final selected = _messages
        .where((m) => _selectedMessageIds.contains(m.id))
        .toList();
    // Sort by time
    selected.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return selected.map((m) => m.body).join('\n\n');
  }

  void _jumpToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(position);
      }
    }
  }
}
