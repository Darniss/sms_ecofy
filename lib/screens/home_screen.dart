import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '/config/env_config.dart';
import '/core/algorithms.dart';
import '/data/sample_sms_data.dart';
import '/utils/app_icons.dart';
import '/utils/storage_service.dart';
import '/utils/theme.dart';
import '/utils/time_helper.dart';
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
  List<SmsMessage> _allMessages = [];
  List<SmsMessage> _timeFilteredMessages = [];
  Map<String, int> _summary = {};

  // UI State
  String _activeTimelineFilter = 'Day';
  String _activeCategoryTab = 'Personal';
  List<String> _dynamicDateChips = [];
  int _selectedDateChipIndex = 0;

  final List<String> _timelineFilters = [
    'All',
    'Day',
    'Weekly',
    'Monthly',
    'Yearly',
  ];
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
      loadedMessages = sampleSmsList;
      _summary = summaryData;
    }

    final starredIds = await _storageService.getStarredIds();
    for (var msg in loadedMessages) {
      if (starredIds.contains(msg.id)) {
        msg.isStarred = true;
      }
    }

    setState(() {
      _allMessages = loadedMessages;
      _isLoading = false;
      _updateDynamicChips();
      _filterMessages();
    });
  }

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
      case 'Yearly':
        _dynamicDateChips = TimeHelper.generateYearChips();
        break;
      case 'All':
      default:
        _dynamicDateChips = [];
    }
    _selectedDateChipIndex = 0;
  }

  void _filterMessages() {
    String selectedChip = '';
    if (_dynamicDateChips.isNotEmpty &&
        _selectedDateChipIndex < _dynamicDateChips.length) {
      selectedChip = _dynamicDateChips[_selectedDateChipIndex];
    } else if (_activeTimelineFilter != 'All') {
      _timeFilteredMessages = [];
      return;
    }

    _timeFilteredMessages = TimeHelper.filterMessagesByTime(
      _allMessages,
      _activeTimelineFilter,
      selectedChip,
    );
  }

  List<SmsMessage> get _filteredMessages {
    List<SmsMessage> messagesToFilter = _timeFilteredMessages;

    if (_activeCategoryTab == 'Starred') {
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
      return m.category.name.toLowerCase() == _activeCategoryTab.toLowerCase();
    }).toList();
  }

  void _toggleStar(SmsMessage message) {
    setState(() {
      message.isStarred = !message.isStarred;
    });
    _storageService.starMessage(message.id, message.isStarred);
  }

  void _deleteMessage(SmsMessage message, int index) {
    final int masterIndex = _allMessages.indexOf(message);
    if (masterIndex == -1) return;

    // Remove from the master data list and call setState
    setState(() {
      _allMessages.removeAt(masterIndex);
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
  }

  void _undoDelete(SmsMessage message, int masterIndex) {
    // Add the data back and call setState
    setState(() {
      if (masterIndex <= _allMessages.length) {
        _allMessages.insert(masterIndex, message);
      } else {
        _allMessages.add(message);
      }
      _filterMessages();
    });
  }

  // --- 1. & 2. UPDATED: Main build method ---
  @override
  Widget build(BuildContext context) {
    // This Scaffold is removed from your original file.
    // This widget now returns a Column directly, to be placed inside
    // the MainNavigationScreen's Scaffold body.
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          // --- 2. Using a Column for "sticky" headers ---
          : Column(
              children: [
                _buildTimelineFilter(),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Visibility(
                    visible: _activeTimelineFilter != 'All',
                    child: _buildDateScroller(),
                  ),
                ),
                SummaryCardsSection(summaryData: _summary),
                _buildCategoryTabs(),

                // --- 2. This Expanded makes the list scrollable below ---
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: _buildMessageList(),
                  ),
                ),
              ],
            ),
      // We also fixed the Hero tag conflict by removing this FAB
      // If you need it, add it to MainNavigationScreen
      floatingActionButton: FloatingActionButton(
        heroTag: 'homeScreenFab',
        onPressed: () {},
        child: const Icon(AppIcons.fabIcon, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // --- 1. UPDATED: AppBar build method ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'SMS Ecofy',
        // '🌿 SMS Ecofy',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      // centerTitle: true,
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
      // --- 1. FIX: The 'bottom' property is removed ---
      // This removes the 1px divider line under the AppBar.
    );
  }

  Widget _buildOverflowMenu() {
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

  // --- 3. UPDATED: Date Scroller build method ---
  Widget _buildDateScroller() {
    final chipTheme = Theme.of(context).chipTheme;
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      margin: const EdgeInsets.only(left: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dynamicDateChips.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedDateChipIndex == index;
          final chipText = _dynamicDateChips[index];

          // --- START OF THE FIX ---
          // We check which filter is active to decide which chip to build
          if (_activeTimelineFilter == 'Day') {
            // --- This is your special chip for 'Day' ---
            final parts = chipText.split(',');
            final dayOfWeek = parts[0]; // "Sat"
            final dayOfMonth = parts[1].trim().split(' ')[1]; // "1"

            return GestureDetector(
              onTap: () => setState(() {
                _selectedDateChipIndex = index;
                _filterMessages();
              }),
              child: Container(
                width: 48,
                margin: const EdgeInsets.only(right: 10.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? kEcoGreen.withOpacity(0.1)
                      : chipTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: isSelected
                        ? kEcoGreen
                        : chipTheme.side?.color ?? Colors.grey,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayOfWeek,
                      style: TextStyle(
                        color: isSelected
                            ? kEcoGreen
                            : chipTheme.labelStyle?.color,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      dayOfMonth,
                      style: TextStyle(
                        color: isSelected
                            ? kEcoGreen
                            : chipTheme.labelStyle?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // --- This is the simple chip for 'Weekly' and 'Monthly' ---
            return GestureDetector(
              onTap: () => setState(() {
                _selectedDateChipIndex = index;
                _filterMessages();
              }),
              child: Container(
                // Width is not fixed, it's dynamic
                margin: const EdgeInsets.only(right: 10.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? kEcoGreen.withOpacity(0.1)
                      : chipTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: isSelected
                        ? kEcoGreen
                        : chipTheme.side?.color ?? Colors.grey,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  chipText, // "Week 44" or "November"
                  style: TextStyle(
                    color: isSelected ? kEcoGreen : chipTheme.labelStyle?.color,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }
          // --- END OF THE FIX ---
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

  // --- 2. UPDATED: Message List build method ---
  Widget _buildMessageList() {
    final messages = _filteredMessages;

    if (messages.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
          ),
        ],
      );
    }

    // --- REVERTED to ListView.separated ---
    return ListView.separated(
      itemCount: messages.length,
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 80.0),
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Theme.of(context).dividerColor, indent: 56),
      itemBuilder: (context, index) {
        final message = messages[index];
        // Pass the index to the build method
        return _buildSlidableMessageListItem(message, index);
      },
    );
    // --- END OF REVERT ---
  }

  Widget _buildSlidableMessageListItem(SmsMessage message, int index) {
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

      switch (message.transactionType) {
        // ... (your switch case logic)
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
      key: Key(message.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            // Pass index to delete method
            _deleteMessage(message, index);
          },
        ),
        children: [
          SlidableAction(
            onPressed: (context) => _deleteMessage(message, index),
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _toggleStar(message),
            backgroundColor: const Color(0xFFFDB813),
            foregroundColor: Colors.white,
            icon: message.isStarred ? Icons.star : Icons.star_border,
            label: message.isStarred ? 'Unstar' : 'Star',
          ),
        ],
      ),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              SmsAnalyzer.getEmojiForSentiment(message.sentiment),
              style: const TextStyle(fontSize: 20),
            ),
            if (message.isStarred)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(Icons.star, color: Colors.amber[600], size: 12.0),
              ),
          ],
        ),
        onTap: () {
          // Open message detail
        },
      ),
    );
    // return Slidable(
    //   key: Key(message.id),
    //   // ... (your startActionPane and endActionPane are unchanged) ...
    //   startActionPane: ActionPane(
    //     motion: const ScrollMotion(),
    //     dismissible: DismissiblePane(
    //       onDismissed: () {
    //         _deleteMessage(message);
    //       },
    //     ),
    //     children: [
    //       SlidableAction(
    //         onPressed: (context) => _deleteMessage(message),
    //         backgroundColor: const Color(0xFFFE4A49),
    //         foregroundColor: Colors.white,
    //         icon: Icons.delete,
    //         label: 'Delete',
    //       ),
    //     ],
    //   ),
    //   endActionPane: ActionPane(
    //     motion: const ScrollMotion(),
    //     children: [
    //       SlidableAction(
    //         onPressed: (context) => _toggleStar(message),
    //         backgroundColor: const Color(0xFFFDB813),
    //         foregroundColor: Colors.white,
    //         icon: message.isStarred ? Icons.star : Icons.star_border,
    //         label: message.isStarred ? 'Unstar' : 'Star',
    //       ),
    //     ],
    //   ),
    //   child: ListTile(
    //     contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
    //     leading: CircleAvatar(
    //       backgroundColor: Theme.of(context).colorScheme.background,
    //       child: Icon(getIconForSender(message.sender), color: kEcoGreen),
    //     ),
    //     title: Text(
    //       message.sender,
    //       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    //     ),
    //     subtitle: Text(
    //       message.body,
    //       maxLines: 1,
    //       overflow: TextOverflow.ellipsis,
    //       style: TextStyle(
    //         color: Theme.of(context).textTheme.bodySmall?.color,
    //         fontSize: 14,
    //       ),
    //     ),

    //     // --- START OF THE FIX (Using a Row) ---
    //     // This layout is horizontally arranged, so its height is
    //     // only as tall as the largest child (the emoji).
    //     // This CANNOT overflow vertically.
    //     trailing: Row(
    //       mainAxisSize: MainAxisSize.min,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         Text(
    //           SmsAnalyzer.getEmojiForSentiment(message.sentiment),
    //           style: const TextStyle(fontSize: 20),
    //         ),
    //         if (message.isStarred)
    //           Padding(
    //             padding: const EdgeInsets.only(left: 4.0),
    //             child: Icon(Icons.star, color: Colors.amber[600], size: 12.0),
    //           ),
    //       ],
    //     ),

    //     // --- END OF THE FIX ---
    //     onTap: () {
    //       // Open message detail
    //     },
    //   ),
    // );
  }
}
