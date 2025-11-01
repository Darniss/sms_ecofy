import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/utils/app_icons.dart';
import '/utils/storage_service.dart';
import '/utils/theme.dart';

class SummaryCardData {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final Color tint;
  final int value;

  SummaryCardData({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.tint,
    required this.value,
  });
}

class SummaryCardsSection extends StatefulWidget {
  final Map<String, int> summaryData;
  const SummaryCardsSection({super.key, required this.summaryData});

  @override
  State<SummaryCardsSection> createState() => _SummaryCardsSectionState();
}

class _SummaryCardsSectionState extends State<SummaryCardsSection> {
  final StorageService _storageService = StorageService();

  String _layoutType = 'grid';
  List<String> _selectedCardIds = ['offers', 'orders', 'travel', 'alerts'];
  late Map<String, SummaryCardData> _allCards;

  // --- NEW: State for interactive pie chart ---
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // --- (updateAllCardsMap, didUpdateWidget, loadPreferences, setLayoutType, showCustomizeDialog...
  // ... all these methods remain unchanged) ---

  void _updateAllCardsMap() {
    _allCards = {
      'offers': SummaryCardData(
        id: 'offers',
        title: 'Offers',
        icon: AppIcons.offers,
        color: kEcoGreen,
        tint: kEcoGreen.withOpacity(0.1),
        value: widget.summaryData['offers'] ?? 0,
      ),
      'orders': SummaryCardData(
        id: 'orders',
        title: 'Orders',
        icon: AppIcons.orders,
        color: kSkyBlue,
        tint: kSkyBlue.withOpacity(0.1),
        value: widget.summaryData['orders'] ?? 0,
      ),
      'travel': SummaryCardData(
        id: 'travel',
        title: 'Travel',
        icon: AppIcons.travel,
        color: kSkyBlue,
        tint: kSkyBlue.withOpacity(0.1),
        value: widget.summaryData['travel'] ?? 0,
      ),
      'alerts': SummaryCardData(
        id: 'alerts',
        title: 'Alerts',
        icon: AppIcons.alerts,
        color: kWarningYellow,
        tint: kWarningYellow.withOpacity(0.1),
        value: widget.summaryData['alerts'] ?? 0,
      ),
      'spam': SummaryCardData(
        id: 'spam',
        title: 'Spam',
        icon: AppIcons.spam,
        color: kSpamOrange,
        tint: kSpamOrange.withOpacity(0.1),
        value: widget.summaryData['spam'] ?? 0,
      ),
      'pim': SummaryCardData(
        id: 'pim',
        title: 'PIM',
        icon: AppIcons.pim,
        color: kPimPurple,
        tint: kPimPurple.withOpacity(0.1),
        value: widget.summaryData['pim'] ?? 0,
      ),
      'carbon': SummaryCardData(
        id: 'carbon',
        title: 'Carbon Score',
        icon: AppIcons.carbon,
        color: kCarbonGrey,
        tint: kCarbonGrey.withOpacity(0.1),
        value: widget.summaryData['carbon'] ?? 0,
      ),
      'trust': SummaryCardData(
        id: 'trust',
        title: 'Trust Score',
        icon: AppIcons.trust,
        color: kTrustBlue,
        tint: kTrustBlue.withOpacity(0.1),
        value: widget.summaryData['trust'] ?? 0,
      ),
    };
  }

  @override
  void didUpdateWidget(covariant SummaryCardsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summaryData != widget.summaryData) {
      _updateAllCardsMap();
      // Reset touched index when data changes
      _touchedIndex = -1;
    }
  }

  Future<void> _loadPreferences() async {
    _updateAllCardsMap();
    final layout = await _storageService.getSummaryCardLayout();
    final cards = await _storageService.getSummaryCardSelection();
    setState(() {
      _layoutType = layout;
      if (cards.isNotEmpty) {
        _selectedCardIds = cards;
      }
    });
  }

  Future<void> _setLayoutType(String type) async {
    setState(() => _layoutType = type);
    await _storageService.setSummaryCardLayout(type);
  }

  void _showCustomizeDialog() {
    List<String> tempSelection = List.from(_selectedCardIds);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Customize Summary'),
              content: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _allCards.values.map((card) {
                    final isSelected = tempSelection.contains(card.id);
                    return FilterChip(
                      label: Text(card.title),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            if (tempSelection.length < 4) {
                              tempSelection.add(card.id);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Only 4 cards can be selected.',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            tempSelection.remove(card.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (tempSelection.length > 4) {
                      return;
                    }
                    setState(() => _selectedCardIds = tempSelection);
                    _storageService.setSummaryCardSelection(tempSelection);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildHeader(), _buildLayout()]);
  }

  Widget _buildHeader() {
    // ... (Your _buildHeader method is unchanged) ...
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text(
            'Summary',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              AppIcons.gridView,
              color: _layoutType == 'grid' ? kEcoGreen : Colors.grey,
            ),
            onPressed: () => _setLayoutType('grid'),
          ),
          IconButton(
            icon: Icon(
              AppIcons.listView,
              color: _layoutType == 'list' ? kEcoGreen : Colors.grey,
            ),
            onPressed: () => _setLayoutType('list'),
          ),
          IconButton(
            icon: Icon(
              AppIcons.pieChart,
              color: _layoutType == 'pie' ? kEcoGreen : Colors.grey,
            ),
            onPressed: () => _setLayoutType('pie'),
          ),
          IconButton(
            icon: const Icon(AppIcons.customize, size: 20, color: Colors.grey),
            onPressed: _showCustomizeDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildLayout() {
    if (_allCards.isEmpty) {
      _updateAllCardsMap();
    }

    final selectedCards = _selectedCardIds
        .map((id) => _allCards[id])
        .where((card) => card != null)
        .map((card) => card!)
        .toList();

    switch (_layoutType) {
      case 'list':
        return _buildListView(selectedCards);
      case 'pie':
        return _buildPieChartView(selectedCards);
      case 'grid':
      default:
        return _buildGridView(selectedCards);
    }
  }

  // --- UPDATED: Grid View ---
  Widget _buildGridView(List<SummaryCardData> cards) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1.8,
      ),
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final card = cards[index];
        return _buildCenteredSummaryCard(card);
      },
    );
  }

  // --- NEW (Reverted to your original style, but centered) ---
  Widget _buildCenteredSummaryCard(SummaryCardData card) {
    // This is your original card layout, with two changes:
    // 1. Column's crossAxisAlignment is set to CrossAxisAlignment.center
    // 2. The Container's decoration uses Theme.of(context).cardColor for theme-awareness

    return Container(
      decoration: BoxDecoration(
        // Use theme card color and your original tint
        color: Theme.of(context).brightness == Brightness.light
            ? card.tint
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        // boxShadow: [
        //   // Optional: Kept my subtle shadow. Remove if you don't like it.
        //   BoxShadow(
        //     color: Theme.of(context).shadowColor.withOpacity(0.05),
        //     blurRadius: 10.0,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Padding(
        // Reverted to your original padding
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // --- FIX: This is the change you wanted ---
          crossAxisAlignment:
              CrossAxisAlignment.center, // Was CrossAxisAlignment.start
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reverted to your original Icon
            Icon(card.icon, color: card.color, size: 28),
            // Reverted to your original SizedBox
            const SizedBox(height: 8),
            // Reverted to your original Text structure
            Text(
              '${card.value} ${card.title}',
              textAlign:
                  TextAlign.center, // Added for text centering if it wraps
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              maxLines: 2, // Allow for wrapping
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // // --- UPDATED: Summary Card ---
  // Widget _buildSummaryCard(SummaryCardData card) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).cardColor, // Use theme card color
  //       borderRadius: BorderRadius.circular(16.0),
  //       boxShadow: [
  //         // Add consistent shadow
  //         BoxShadow(
  //           color: Theme.of(context).shadowColor.withOpacity(0.05),
  //           blurRadius: 10.0,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(12.0), // Consistent padding
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           // Icon with its colored tint background
  //           CircleAvatar(
  //             radius: 20,
  //             backgroundColor: card.tint,
  //             child: Icon(card.icon, color: card.color, size: 22),
  //           ),
  //           const SizedBox(height: 12),
  //           // Value
  //           Text(
  //             card.value.toString(),
  //             style: TextStyle(
  //               fontSize: 20,
  //               fontWeight: FontWeight.bold,
  //               color: Theme.of(context).textTheme.bodyLarge?.color,
  //             ),
  //           ),
  //           const SizedBox(height: 4),
  //           // Title
  //           Text(
  //             card.title,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //               fontSize: 14,
  //               color: Theme.of(context).textTheme.bodySmall?.color,
  //             ),
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildListView(List<SummaryCardData> cards) {
    // ... (Your _buildListView method is unchanged) ...
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final card = cards[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          color: card.tint.withOpacity(0.5),
          child: ListTile(
            leading: Icon(card.icon, color: card.color, size: 28),
            title: Text(
              card.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              card.value.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  // --- NEW: Pie Chart Legend Widget ---
  Widget _buildPieChartLegends(List<SummaryCardData> cards) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: cards.map((card) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: card.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              card.title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // --- UPDATED: Pie Chart View ---
  Widget _buildPieChartView(List<SummaryCardData> cards) {
    final total = cards.fold<double>(0, (sum, item) => sum + item.value);
    if (total == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("No data for chart"),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                // Add touch interaction
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 4, // Add space between sections
                centerSpaceRadius: 60, // Make it a "doughnut" chart
                sections: List.generate(cards.length, (index) {
                  final card = cards[index];
                  final isTouched = index == _touchedIndex;
                  final double radius = isTouched ? 60.0 : 50.0;
                  final double percentage = (card.value / total * 100);

                  return PieChartSectionData(
                    color: card.color, // This solid color will be used
                    value: card.value.toDouble(),
                    // Show percentage only on tap
                    title: isTouched ? '${percentage.toStringAsFixed(0)}%' : '',
                    radius: radius,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),

                    // --- FIX: Removed the 'gradient' parameter ---
                    // The 'gradient' property was causing the error
                    // as it's not supported in your fl_chart version.
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Add the legends
          _buildPieChartLegends(cards),
        ],
      ),
    );
  }
}
