import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Import slidable
import '/config/env_config.dart';
import '/core/algorithms.dart';
import '/data/sample_sms_data.dart';
import '/utils/app_icons.dart';
import '/utils/storage_service.dart';
import '/utils/theme.dart';
import '/widgets/summary_cards_section.dart';
import '/utils/time_helper.dart'; // Import the new time helper

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();

  // State variables
  bool _isLoading = true;
  List<SmsMessage> _allMessages = []; // Master list of all messages
  List<SmsMessage> _timeFilteredMessages = []; // List after time filter
  Map<String, int> _summary = {};

  // UI State
  String _activeTimelineFilter = 'Day'; // Default to 'Day'
  String _activeCategoryTab = 'Personal';

  // --- NEW DYNAMIC TIME STATE ---
  List<String> _dynamicDateChips = [];
  int _selectedDateChipIndex = 0;

  // Static data for filters
  final List<String> _timelineFilters = ['All', 'Day', 'Weekly', 'Monthly'];
  final List<String> _categoryTabs = [
    'Personal',
    'Transactions',
    'Promotions',
    'OTP',
    'Starred',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    List<SmsMessage> loadedMessages = [];
    if (EnvironmentConfig.isTestMode) {
      loadedMessages = sampleSmsList;
      _summary = summaryData;
    } else {
      // TODO: Add logic to fetch real SMS messages
      loadedMessages = sampleSmsList;
      _summary = summaryData;
    }

    // --- NEW: Load starred status ---
    final starredIds = await _storageService.getStarredIds();
    for (var msg in loadedMessages) {
      if (starredIds.contains(msg.id)) {
        msg.isStarred = true;
      }
    }

    setState(() {
      _allMessages = loadedMessages;
      _isLoading = false;
      // --- NEW: Initialize filters ---
      _updateDynamicChips();
      _filterMessages();
    });
  }

  // --- NEW: Method to update the dynamic date chips ---
  void _updateDynamicChips() {
    switch (_activeTimelineFilter) {
      case 'Day':
        _dynamicDateChips = TimeHelper.generateDayChips();
        break;
      case 'Weekly':
        _dynamicDateChips = TimeHelper.generateWeekChips();
        break;
      case 'Monthly':
        _dynamicDateChips = TimeHelper.generateMonthChips();
        break;
      case 'All':
      default:
        _dynamicDateChips = [];
    }
    // Reset selected chip index, ensuring it's valid
    _selectedDateChipIndex = 0;
  }

  // --- NEW: Method to apply time filter ---
  void _filterMessages() {
    String selectedChip = '';
    if (_dynamicDateChips.isNotEmpty &&
        _selectedDateChipIndex < _dynamicDateChips.length) {
      selectedChip = _dynamicDateChips[_selectedDateChipIndex];
    } else if (_activeTimelineFilter != 'All') {
      // No chips to select from, but filter is not 'All', so show nothing
      _timeFilteredMessages = [];
      return;
    }

    // Apply time filter first
    _timeFilteredMessages = TimeHelper.filterMessagesByTime(
      _allMessages,
      _activeTimelineFilter,
      selectedChip,
    );
    // The _filteredMessages getter will now apply category filter
  }

  // --- UPDATED: Getter now filters by category from the _timeFilteredMessages ---
  List<SmsMessage> get _filteredMessages {
    // Start with the time-filtered list
    List<SmsMessage> messagesToFilter = _timeFilteredMessages;

    // --- NEW LOGIC FOR STARRED ---
    if (_activeCategoryTab == 'Starred') {
      // Show starred messages from the time-filtered list
      return messagesToFilter.where((m) => m.isStarred).toList();
    }

    if (_activeCategoryTab == 'OTP') {
      return messagesToFilter
          .where((m) => m.transactionType == TransactionType.otp)
          .toList();
    }

    return messagesToFilter.where((m) {
      if (_activeCategoryTab == 'Transactions' &&
          m.transactionType == TransactionType.otp) {
        return false;
      }
      // Apply category filter
      return m.category.name.toLowerCase() == _activeCategoryTab.toLowerCase();
    }).toList();
  }

  // --- NEW: Swipe Action Handlers ---

  void _toggleStar(SmsMessage message) {
    setState(() {
      message.isStarred = !message.isStarred;
    });
    _storageService.starMessage(message.id, message.isStarred);
    // If in starred tab, the list will rebuild and item might disappear
    // This is handled automatically by setState and the getter
  }

  void _deleteMessage(SmsMessage message) {
    // Find the message in both lists
    final int masterIndex = _allMessages.indexOf(message);
    if (masterIndex == -1) return; // Safety check

    setState(() {
      _allMessages.removeAt(masterIndex);
      // Re-run the time filter to update the UI list
      _filterMessages();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => _undoDelete(message, masterIndex),
        ),
      ),
    );

    // TODO: Add to local storage for permanent deletion if needed
  }

  void _undoDelete(SmsMessage message, int masterIndex) {
    setState(() {
      // Add back to the master list at its original position
      _allMessages.insert(masterIndex, message);
      // Re-run the filter to put it back in the time-filtered list
      _filterMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: [
                  _buildTimelineFilter(),
                  // --- UPDATED: Animated date scroller ---
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Visibility(
                      // Show scroller if filter is not 'All'
                      visible: _activeTimelineFilter != 'All',
                      child: _buildDateScroller(),
                    ),
                  ),
                  SummaryCardsSection(summaryData: _summary),
                  _buildCategoryTabs(),
                  _buildMessageList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'homeScreenFab',
        onPressed: () {},
        child: const Icon(AppIcons.fabIcon, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // ... (Your _buildAppBar code is unchanged)
    return AppBar(
      title: const Text(
        '🌿 SMS Ecofy',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: const Icon(AppIcons.search, size: 28),
          onPressed: () {
            // Handle search
          },
        ),
        _buildOverflowMenu(),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Theme.of(context).dividerColor, height: 1.0),
      ),
    );
  }

  Widget _buildOverflowMenu() {
    // ... (Your _buildOverflowMenu code is unchanged)
    return PopupMenuButton<String>(
      icon: const Icon(AppIcons.menu),
      onSelected: (value) {
        if (value == 'theme') {
          final themeProvider = Provider.of<ThemeProvider>(
            context,
            listen: false,
          );
          bool isCurrentlyDark = themeProvider.themeMode == ThemeMode.dark;
          themeProvider.toggleTheme(!isCurrentlyDark);
        } else if (value == 'dev_mode') {
          setState(() {
            EnvironmentConfig.isTestMode = !EnvironmentConfig.isTestMode;
          });
          _loadData();
        }
      },
      itemBuilder: (BuildContext context) {
        final bool isCurrentlyDark =
            Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

        return [
          PopupMenuItem<String>(
            value: 'theme',
            child: Row(
              children: [
                Icon(
                  isCurrentlyDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 12),
                Text(isCurrentlyDark ? 'Light Theme' : 'Dark Theme'),
              ],
            ),
          ),
          if (!EnvironmentConfig.isProduction)
            PopupMenuItem<String>(
              value: 'dev_mode',
              child: Row(
                children: [
                  Icon(
                    EnvironmentConfig.isTestMode
                        ? Icons.bug_report_rounded
                        : Icons.bug_report_outlined,
                    color: EnvironmentConfig.isTestMode
                        ? kEcoGreen
                        : Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    EnvironmentConfig.isTestMode
                        ? 'Disable Dev Mode'
                        : 'Enable Dev Mode',
                  ),
                ],
              ),
            ),
        ];
      },
    );
  }

  Widget _buildTimelineFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      alignment: Alignment.centerRight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: _timelineFilters.map((filter) {
            bool isActive = _activeTimelineFilter == filter;
            return GestureDetector(
              // --- UPDATED: onTap now updates filters ---
              onTap: () => setState(() {
                _activeTimelineFilter = filter;
                _updateDynamicChips();
                _filterMessages();
              }),
              child: Container(
                margin: const EdgeInsets.only(left: 8.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? kEcoGreen
                      : Theme.of(context).chipTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: isActive
                        ? kEcoGreen
                        : Theme.of(context).dividerColor,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- UPDATED: Date Scroller now uses dynamic data ---
  Widget _buildDateScroller() {
    final chipTheme = Theme.of(context).chipTheme;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      margin: const EdgeInsets.only(left: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dynamicDateChips.length, // Use dynamic count
        itemBuilder: (context, index) {
          bool isSelected = _selectedDateChipIndex == index;
          final chipText = _dynamicDateChips[index]; // Use dynamic text

          return GestureDetector(
            // --- UPDATED: onTap updates index and filters ---
            onTap: () => setState(() {
              _selectedDateChipIndex = index;
              _filterMessages();
            }),
            child: Container(
              margin: const EdgeInsets.only(right: 10.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? kEcoGreen.withOpacity(0.1)
                    : chipTheme.backgroundColor,
                borderRadius: (chipTheme.shape is RoundedRectangleBorder)
                    ? (chipTheme.shape as RoundedRectangleBorder).borderRadius
                    : BorderRadius.circular(20.0),
                border: Border.all(
                  color: isSelected
                      ? kEcoGreen
                      : chipTheme.side?.color ?? Colors.grey,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                chipText, // Use dynamic text
                style: TextStyle(
                  color: isSelected ? kEcoGreen : chipTheme.labelStyle?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categoryTabs.length,
        itemBuilder: (context, index) {
          final category = _categoryTabs[index];
          bool isActive = _activeCategoryTab == category;
          return GestureDetector(
            // --- UPDATED: onTap must call setState to rebuild message list ---
            onTap: () => setState(() => _activeCategoryTab = category),
            child: Container(
              margin: const EdgeInsets.only(right: 10.0),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: isActive
                    ? kEcoGreen.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20.0),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isActive
                      ? kEcoGreen
                      : Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageList() {
    final messages = _filteredMessages; // Getter handles all filtering

    if (messages.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 60,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _activeTimelineFilter == 'All'
                  ? 'No messages in $_activeCategoryTab'
                  : 'No messages in $_activeCategoryTab\nfor this time period',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: messages.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 80.0),
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Theme.of(context).dividerColor, indent: 56),
      itemBuilder: (context, index) {
        final message = messages[index];
        // --- UPDATED: Use the new Slidable item builder ---
        return _buildSlidableMessageListItem(message);
      },
    );
  }

  // --- NEW: Slidable Message List Item ---
  Widget _buildSlidableMessageListItem(SmsMessage message) {
    // Helper to get icon for sender (copied from your old _buildMessageListItem)
    IconData getIconForSender(String sender) {
      String s = sender.toLowerCase();
      if (s.contains('hdfc') || s.contains('icici') || s.contains('axis'))
        return AppIcons.finance;
      if (s.contains('amazon') || s.contains('flipkart'))
        return AppIcons.orders;
      if (s.contains('indigo') || s.contains('makemytrip'))
        return AppIcons.travel;
      if (s.contains('airtel') || s.contains('jio') || s.contains('vi'))
        return Icons.receipt_long_rounded;
      if (s.contains('google') || s.contains('facebook'))
        return Icons.password_rounded;

      // Fallback from your original code
      switch (message.transactionType) {
        case TransactionType.order:
          return AppIcons.orders;
        case TransactionType.bank:
          return AppIcons.finance;
        case TransactionType.travel:
          return AppIcons.travel;
        case TransactionType.bill:
          return Icons.receipt_long_rounded;
        case TransactionType.offer:
          return AppIcons.offers;
        case TransactionType.spam:
          return AppIcons.spam;
        case TransactionType.otp:
          return Icons.password_rounded;
        case TransactionType.alert:
          return Icons.warning_amber_rounded;
        case TransactionType.social:
          return Icons.group_rounded;
        default:
          return Icons.person_outline;
      }
    }

    return Slidable(
      // --- IMPORTANT: Use a unique key for each item ---
      key: Key(message.id),

      // --- Left-to-Right Swipe (Delete) ---
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        // A confirmation panel that appears when you slide
        dismissible: DismissiblePane(
          onDismissed: () {
            _deleteMessage(message);
          },
        ),
        children: [
          SlidableAction(
            onPressed: (context) => _deleteMessage(message),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),

      // --- Right-to-Left Swipe (Star) ---
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _toggleStar(message),
            backgroundColor: const Color(0xFFFDB813), // Amber/Gold color
            foregroundColor: Colors.white,
            icon: message.isStarred ? Icons.star : Icons.star_border,
            label: message.isStarred ? 'Unstar' : 'Star',
          ),
        ],
      ),

      // --- The content of the list item ---
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.background,
          child: Icon(getIconForSender(message.sender), color: kEcoGreen),
        ),
        title: Text(
          message.sender,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          message.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 14,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              SmsAnalyzer.getEmojiForSentiment(message.sentiment),
              // We keep the emoji size from before
              style: const TextStyle(fontSize: 22),
            ),
            if (message.isStarred)
              Padding(
                // Reduce padding to 1.0px
                padding: const EdgeInsets.only(top: 1.0), // Was 2.0
                child: Icon(
                  Icons.star,
                  color: Colors.amber[600],
                  // Reduce icon size to 10.0px
                  size: 10.0, // Was 12.0
                ),
              )
            else
              // Match the new total height: 1.0 (padding) + 10.0 (icon) = 11.0
              const SizedBox(height: 11.0), // Was 14.0
          ],
        ),
        onTap: () {
          // Open message detail
        },
      ),
    );
  }
}
