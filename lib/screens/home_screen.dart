import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/config/env_config.dart';
import '/core/algorithms.dart';
import '/data/sample_sms_data.dart';
import '/utils/app_icons.dart';
import '/utils/storage_service.dart';
import '/utils/theme.dart';
import '/widgets/summary_cards_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();

  // State variables
  bool _isLoading = true;
  List<SmsMessage> _messages = [];
  Map<String, int> _summary = {};

  // UI State
  String _activeTimelineFilter = 'All';
  String _activeCategoryTab = 'Personal';
  int _selectedDateIndex = 2; // Default to 'Oct 30'

  // Mock data for filters
  final List<String> _timelineFilters = ['All', 'Day', 'Weekly', 'Monthly'];
  final List<String> _dateChips = [
    'Oct 28',
    'Oct 29',
    'Oct 30',
    'Oct 31',
    'Nov 1',
  ];
  // --- UPDATED CATEGORY TABS ---
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

    // Simulate data fetching
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real 'production' app, you would query for live SMS
    // In 'test' mode, you'd use sample data.
    List<SmsMessage> loadedMessages = [];
    if (EnvironmentConfig.isTestMode) {
      loadedMessages = sampleSmsList;
      _summary = summaryData;
    } else {
      // TODO: Add logic to fetch real SMS messages
      // For now, we'll use sample data if not in test mode but empty
      loadedMessages = sampleSmsList;
      _summary = summaryData; // You would calculate this from real data
    }

    setState(() {
      _messages = loadedMessages;
      _isLoading = false;
    });
  }

  // Filter messages based on the active category tab
  List<SmsMessage> get _filteredMessages {
    if (_activeCategoryTab == 'Starred') {
      // Placeholder for starred logic
      return _messages
          .where((m) => m.category == SmsCategory.personal)
          .toList();
    }

    // --- NEW LOGIC FOR OTP TAB ---
    if (_activeCategoryTab == 'OTP') {
      return _messages
          .where((m) => m.transactionType == TransactionType.otp)
          .toList();
    }

    // --- UPDATED DEFAULT LOGIC ---
    // This will now handle Personal, Transactions, and Promotions
    return _messages.where((m) {
      // Exclude OTPs from the main 'Transactions' tab to avoid duplication
      if (_activeCategoryTab == 'Transactions' &&
          m.transactionType == TransactionType.otp) {
        return false;
      }
      return m.category.name.toLowerCase() == _activeCategoryTab.toLowerCase();
    }).toList();
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
                  _buildDateScroller(),
                  // Use the new SummaryCardsSection widget
                  SummaryCardsSection(summaryData: _summary),
                  _buildCategoryTabs(),
                  _buildMessageList(),
                ],
              ),
            ),
      // Updated FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Compose new SMS
        },
        child: const Icon(AppIcons.fabIcon, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // BottomNavBar is now in MainNavigationScreen
    );
  }

  // --- AppBar ---
  PreferredSizeWidget _buildAppBar() {
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
        // New 3-dot overflow menu
        _buildOverflowMenu(),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Theme.of(context).dividerColor, height: 1.0),
      ),
    );
  }

  // --- Overflow Menu ---
  Widget _buildOverflowMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(AppIcons.menu),
      onSelected: (value) {
        if (value == 'theme') {
          // --- FIX 2: Call toggleTheme with the correct argument ---
          final themeProvider = Provider.of<ThemeProvider>(
            context,
            listen: false,
          );
          bool isCurrentlyDark = themeProvider.themeMode == ThemeMode.dark;
          themeProvider.toggleTheme(
            !isCurrentlyDark,
          ); // Pass the new desired state
        } else if (value == 'dev_mode') {
          setState(() {
            EnvironmentConfig.isTestMode = !EnvironmentConfig.isTestMode;
          });
          _loadData(); // Reload data based on new mode
        }
      },
      itemBuilder: (BuildContext context) {
        // Get the current theme mode to build the menu item
        final bool isCurrentlyDark =
            Provider.of<ThemeProvider>(context, listen: false).themeMode ==
            ThemeMode.dark;

        return [
          PopupMenuItem<String>(
            value: 'theme',
            child: Row(
              children: [
                Icon(
                  // --- FIX 1: Check themeMode, not isDarkMode ---
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
          // Conditionally show the Dev Mode toggle
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

  // --- Timeline Filter ---
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
              onTap: () => setState(() => _activeTimelineFilter = filter),
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

  // --- Date Scroller ---
  Widget _buildDateScroller() {
    final chipTheme = Theme.of(context).chipTheme;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      margin: const EdgeInsets.only(left: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dateChips.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedDateIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDateIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? kEcoGreen.withOpacity(0.1)
                    : chipTheme.backgroundColor,
                // --- FIX: Cast shape to RoundedRectangleBorder and access its borderRadius property ---
                borderRadius: (chipTheme.shape is RoundedRectangleBorder)
                    ? (chipTheme.shape as RoundedRectangleBorder).borderRadius
                    : BorderRadius.circular(20.0), // Fallback
                border: Border.all(
                  color: isSelected
                      ? kEcoGreen
                      : chipTheme.side?.color ?? Colors.grey,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _dateChips[index],
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

  // --- Summary Cards (Removed) ---
  // This logic is now in lib/widgets/summary_cards_section.dart

  // --- Category Tabs ---
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

  // --- Message List ---
  Widget _buildMessageList() {
    final messages = _filteredMessages;

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
              'No messages in $_activeCategoryTab',
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
      padding: const EdgeInsets.fromLTRB(
        16.0,
        8.0,
        16.0,
        80.0,
      ), // Padding for FAB
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Theme.of(context).dividerColor, indent: 56),
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageListItem(message);
      },
    );
  }

  Widget _buildMessageListItem(SmsMessage message) {
    // Helper to get a placeholder icon based on transaction type
    IconData getIconForType(TransactionType type) {
      switch (type) {
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
          return Icons.password_rounded; // Icon for OTP
        case TransactionType.alert:
          return Icons.warning_amber_rounded; // Icon for Alert
        case TransactionType.social:
          return Icons.group_rounded; // Icon for Social
        default:
          return Icons.person_outline;
      }
    }

    // Helper to get icon for sender
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
      return getIconForType(message.transactionType);
    }

    return ListTile(
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
      trailing: Text(
        SmsAnalyzer.getEmojiForSentiment(message.sentiment),
        style: const TextStyle(fontSize: 24),
      ),
      onTap: () {
        // Open message detail
      },
    );
  }
}
