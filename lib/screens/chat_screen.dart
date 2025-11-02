import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// --- Package Imports ---
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Your Project Imports ---
import '/data/sample_sms_data.dart';
import '/core/algorithms.dart' as alogo_;
import '/widgets/chat_bubble_widget.dart';
import '/utils/storage_service.dart';
import '/services/sms_service.dart';
import '/utils/theme.dart';

class ChatScreen extends StatefulWidget {
  final String sender;
  final List<SmsMessage> messages;
  final String? messageToHighlightId; // <-- For blinking

  const ChatScreen({
    super.key,
    required this.sender,
    required this.messages,
    this.messageToHighlightId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// --- ADD 'SingleTickerProviderStateMixin' for the blink animation ---
class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  // --- State Variables ---
  late List<SmsMessage> _messages;
  bool _isSelectionMode = false;
  final Set<String> _selectedMessageIds = {};

  // For reply bar
  final TextEditingController _replyController = TextEditingController();
  bool _canSend = false;

  // For thread state
  bool _isPinned = false;
  bool _isMuted = false;

  // Services
  final StorageService _storageService = StorageService();
  final SmsService _smsService = SmsService();

  // --- NEW: For scrolling and blinking ---
  late AutoScrollController _scrollController;
  AnimationController? _blinkController;
  Animation<Color?>? _blinkAnimation;
  int _highlightIndex = -1;

  // --- Init & Dispose ---
  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.messages);
    _loadThreadState();

    // --- NEW: Setup ScrollController ---
    _scrollController = AutoScrollController();

    // --- NEW: Setup Blinking ---
    if (widget.messageToHighlightId != null) {
      _highlightIndex = _messages.indexWhere(
        (m) => m.id == widget.messageToHighlightId,
      );

      if (_highlightIndex != -1) {
        _setupBlinkAnimation();
        _scrollToHighlightedMessage();
      }
    }
    // --- END NEW ---

    _replyController.addListener(() {
      setState(() {
        _canSend = _replyController.text.isNotEmpty;
      });
    });

    // Don't auto-scroll to bottom if we are highlighting a message
    if (_highlightIndex == -1) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _jumpToBottom(animated: false),
      );
    }
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
    // --- THIS IS THE FIX (Part 1) ---
    _blinkController?.dispose(); // Dispose if it's not null
    _blinkController = null; // ALWAYS set to null
    // --- END OF FIX ---
    super.dispose();
  }
  // void dispose() {
  //   _replyController.dispose();
  //   _scrollController.dispose();
  //   _blinkController?.dispose(); // <-- Dispose the blink controller
  //   super.dispose();
  // }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AnimatedSwitcher provides a smooth fade between AppBars
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isSelectionMode
              ? _buildSelectionAppBar()
              : _buildDefaultAppBar(),
        ),
      ),
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
      key: const ValueKey('defaultAppBar'), // For AnimatedSwitcher
      title: Text(
        widget.sender,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.phone), onPressed: _makeCall),
        PopupMenuButton<String>(
          onSelected: _onDefaultMenuSelected,
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'move', child: Text('Move to')),
            PopupMenuItem(
              value: 'pin',
              child: Text(_isPinned ? 'Unpin Chat' : 'Pin Chat'),
            ),
            PopupMenuItem(
              value: 'mute',
              child: Text(_isMuted ? 'Unmute Sender' : 'Mute Sender'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
            const PopupMenuItem(value: 'contact', child: Text('View Contact')),
            const PopupMenuItem(value: 'replies', child: Text('Quick Replies')),
            const PopupMenuItem(value: 'block', child: Text('Block Sender')),
            const PopupMenuItem(value: 'report', child: Text('Report Sender')),
          ],
        ),
      ],
    );
  }

  // --- Selection AppBar ---
  AppBar _buildSelectionAppBar() {
    return AppBar(
      key: const ValueKey('selectionAppBar'), // For AnimatedSwitcher
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
            const PopupMenuItem(value: 'share', child: Text('Share SMS')),
            const PopupMenuItem(value: 'move', child: Text('Move to')),
            const PopupMenuItem(value: 'reminder', child: Text('Add Reminder')),
            const PopupMenuItem(value: 'forward', child: Text('Forward SMS')),
          ],
        ),
      ],
    );
  }

  // --- Message List (with Date Separator & Blinking) ---
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController, // Use the AutoScrollController
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        bool showSeparator = false;

        // --- Date Separator Logic ---
        if (index == 0) {
          showSeparator = true;
        } else {
          final prevMessage = _messages[index - 1];
          if (message.timestamp.day != prevMessage.timestamp.day ||
              message.timestamp.month != prevMessage.timestamp.month ||
              message.timestamp.year != prevMessage.timestamp.year) {
            showSeparator = true;
          }
        }

        // --- NEW: Build the bubble widget ---
        Widget bubble = ChatBubbleWidget(
          message: message,
          isSent:
              message.isSent ?? false, // <-- This controls left/right alignment
          isSelected: _selectedMessageIds.contains(message.id),
          onTap: () => _onMessageTap(message),
          onLongPress: () => _onMessageLongPress(message),
        );

        // --- NEW: Apply blink animation if this is the highlighted item ---
        if (index == _highlightIndex &&
            _blinkController != null &&
            _blinkAnimation != null) {
          bubble = AnimatedBuilder(
            animation: _blinkAnimation!,
            builder: (context, child) {
              return Container(
                color: _blinkAnimation!
                    .value, // Apply the blinking highlight color
                child: child,
              );
            },
            child: bubble,
          );
        }

        return Column(
          children: [
            if (showSeparator) _buildDateSeparator(message.timestamp),
            // --- NEW: Wrap in AutoScrollTag for scrolling ---
            AutoScrollTag(
              key: ValueKey(message.id),
              controller: _scrollController,
              index: index,
              child: bubble,
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
      padding: const EdgeInsets.all(
        8.0,
      ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
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
      case 'contact':
        _onViewContact(); // <-- Use flutter_contacts
        break;
      // Add other cases here
    }
  }

  Future<void> _makeCall() async {
    if (!widget.sender.startsWith('+') &&
        !RegExp(r'^[0-9]{10,}$').hasMatch(widget.sender)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot call sender: ${widget.sender}")),
      );
      return;
    }
    final Uri callUri = Uri(scheme: 'tel', path: widget.sender);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Could not launch call")));
    }
  }

  void _onPin() {
    setState(() => _isPinned = !_isPinned);
    _storageService.setThreadPinned(widget.sender, _isPinned);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isPinned ? 'Chat Pinned' : 'Chat Unpinned')),
    );
  }

  void _onMute() {
    setState(() => _isMuted = !_isMuted);
    _storageService.setSenderMuted(widget.sender, _isMuted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isMuted ? 'Sender Muted' : 'Sender Unmuted')),
    );
  }

  void _onDeleteThread() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Thread?'),
        content: const Text(
          'Are you sure you want to permanently delete this conversation?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close chat screen
            },
          ),
        ],
      ),
    );
  }

  // --- NEW: "View Contact" using flutter_contacts ---
  Future<void> _onViewContact() async {
    if (await Permission.contacts.request().isGranted) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      Contact? contact;
      try {
        contact = contacts.firstWhere(
          (c) => c.phones.any(
            (p) =>
                p.number.replaceAll(RegExp(r'[\s()-]'), '') ==
                widget.sender.replaceAll(RegExp(r'[\s()-]'), ''),
          ),
        );
      } catch (e) {
        contact = null; // No match found
      }

      if (contact != null) {
        await FlutterContacts.openExternalView(contact.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No contact found for this number.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contacts permission denied.')),
      );
    }
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
    // Requires 'share_plus' package
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
    setState(() {
      _messages.removeWhere((msg) => _selectedMessageIds.contains(msg.id));
      _exitSelectionMode();
    });
  }

  void _onSelectAll() {
    setState(() {
      if (_selectedMessageIds.length == _messages.length) {
        _selectedMessageIds.clear();
      } else {
        _selectedMessageIds.addAll(_messages.map((m) => m.id));
      }
    });
  }

  // --- Action Handlers (Messaging) ---

  void _onSend() async {
    final body = _replyController.text;
    if (body.isEmpty) return;

    final tempMessage = SmsMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'You', // This sender is not used, isSent=true is
      body: body,
      timestamp: DateTime.now(),
      category: alogo_.SmsCategory.personal,
      sentiment: alogo_.Sentiment.neutral,
      transactionType: alogo_.TransactionType.none,
      isSent: true, // <-- This marks it as a "user" message
    );

    setState(() {
      _messages.add(tempMessage);
    });
    _replyController.clear();
    _jumpToBottom(animated: true);

    await _smsService.sendSms([widget.sender], body);
  }

  // --- Gesture Handlers ---

  void _onMessageTap(SmsMessage message) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedMessageIds.contains(message.id)) {
          _selectedMessageIds.remove(message.id);
        } else {
          _selectedMessageIds.add(message.id);
        }
        if (_selectedMessageIds.isEmpty) {
          _exitSelectionMode();
        }
      });
    }
  }

  void _onMessageLongPress(SmsMessage message) {
    if (!_isSelectionMode) {
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
    final selected = _messages
        .where((m) => _selectedMessageIds.contains(m.id))
        .toList();
    selected.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return selected.map((m) => m.body).join('\n\n');
  }

  // --- NEW: Blink & Scroll Utilities ---
  void _setupBlinkAnimation() {
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _blinkAnimation =
        ColorTween(
            begin: kEcoGreen.withOpacity(0.0), // Start transparent
            end: kEcoGreen.withOpacity(0.3), // Blink to this color
          ).animate(
            CurvedAnimation(parent: _blinkController!, curve: Curves.easeIn),
          )
          ..addStatusListener((status) {
            // Create a looping effect
            if (status == AnimationStatus.completed) {
              _blinkController!.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _blinkController!.forward();
            }
          });

    _blinkController!.forward();
    // Stop blinking after 3 seconds
    // Future.delayed(const Duration(seconds: 3), () {
    //   _blinkController?.dispose();
    //   _blinkController = null;
    //   if (mounted) setState(() {}); // Rebuild to remove the animation color
    // });
      Future.delayed(const Duration(seconds: 3), () {
      // By the time this timer fires, if the user has navigated back,
      // the main dispose() method will have already set _blinkController
      // to null.
      // The '?.' operator (null-aware) will safely do nothing
      // if _blinkController is already null.
      _blinkController?.dispose();
      _blinkController = null;
      // We still must check 'mounted' before calling setState
      if (mounted) {
        setState(() {}); // Rebuild to remove the animation color
      }
    });    
  }

  void _scrollToHighlightedMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.scrollToIndex(
          _highlightIndex,
          preferPosition: AutoScrollPosition.middle,
          duration: const Duration(milliseconds: 300),
        );
      }
    });
  }

  void _jumpToBottom({bool animated = true}) {
    // We must wait for the list to be built
    if (!_scrollController.hasClients) return;

    // Find the last index
    final lastIndex = _messages.isNotEmpty ? _messages.length - 1 : 0;
    if (lastIndex == 0) return;

    _scrollController.scrollToIndex(
      lastIndex,
      preferPosition: AutoScrollPosition.end,
      duration: animated
          ? const Duration(milliseconds: 300)
          : const Duration(milliseconds: 1),
    );
  }
}
