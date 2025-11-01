import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/utils/app_icons.dart';
import '/utils/storage_service.dart';
import '/screens/summary_detail_screen.dart';
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
  int _touchedIndex = -1;

  // --- NEW: State variable to track the expansion state ---
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // ... (All other methods like _updateAllCardsMap, didUpdateWidget,
  // _loadPreferences, _setLayoutType, _showCustomizeDialog remain UNCHANGED) ...

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

  // --- UPDATED: Main build method ---
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        // --- NEW: AnimatedSize wrapper ---
        // This widget will animate the size changes of its child
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child:
              // We use our state variable to show/hide the layout
              _isExpanded ? _buildLayout() : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // --- UPDATED: Header build method ---
  Widget _buildHeader() {
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
          // --- NEW: Expansion Toggle Button ---
          IconButton(
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
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

  // --- _buildLayout is UNCHANGED ---
  Widget _buildLayout() {
    // Ensure _allCards is initialized before use
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

  // --- _buildGridView is UNCHANGED (with the mainAxisExtent fix) ---
  // Widget _buildGridView(List<SummaryCardData> cards) {
  //   return GridView.builder(
  //     padding: const EdgeInsets.all(16.0),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       crossAxisSpacing: 12.0,
  //       mainAxisSpacing: 12.0,
  //       mainAxisExtent: 100, // Fixed height to prevent overflow
  //     ),
  //     itemCount: cards.length,
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemBuilder: (context, index) {
  //       final card = cards[index];
  //       return _buildCenteredSummaryCard(card);
  //     },
  //   );
  // }

  Widget _buildGridView(List<SummaryCardData> cards) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        // --- ADD THIS LINE ---
        // Give each card a fixed height of 110 pixels.
        // You can adjust this value as needed.
        mainAxisExtent: 110,
        // --------------------
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

  Widget _buildCenteredSummaryCard(SummaryCardData card) {
    return InkWell( // NEW
  onTap: () { // NEW
    Navigator.of(context).push(MaterialPageRoute( // NEW
      builder: (context) => SummaryDetailScreen(card: card), // NEW
    ));
  },
  child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? card.tint
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.0),
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).shadowColor.withOpacity(0.05),
        //     blurRadius: 10.0,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(card.icon, color: card.color, size: 28),
            const SizedBox(height: 8),
            Flexible(
                child: Text(
                  '${card.value} ${card.title}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          //   Hero( // NEW
          //   tag: 'summary_icon_${card.id}', // NEW: Unique tag
          //   child: Icon(card.icon, color: card.color, size: 28), // NEW
          // ),
          ],
        ),
      ),
    ));
  }

  // --- _buildListView is UNCHANGED ---
  Widget _buildListView(List<SummaryCardData> cards) {
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

  // --- _buildPieChartLegends is UNCHANGED ---
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

  // --- _buildPieChartView is UNCHANGED (with the gradient fix) ---
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
                // --- FIX for Gesture Error ---
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      // 1. Check for null on the boolean value
                      final bool isInterested =
                          event.isInterestedForInteractions ?? false;

                      // 2. Use the null-safe boolean
                      if (!isInterested ||
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

                // --- End of Gesture Fix ---
                sectionsSpace: 4,
                centerSpaceRadius: 60,
                sections: List.generate(cards.length, (index) {
                  final card = cards[index];
                  final isTouched = index == _touchedIndex;
                  final double radius = isTouched ? 60.0 : 50.0;
                  final double percentage = (card.value / total * 100);

                  return PieChartSectionData(
                    color: card.color,
                    value: card.value.toDouble(),
                    title: isTouched ? '${percentage.toStringAsFixed(0)}%' : '',
                    radius: radius,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- FIX for RenderFlex Overflow ---
          // We constrain the height of the legends and make them scrollable
          // if they don't fit. This guarantees a fixed height.
          SizedBox(
            height: 60, // Max height for the legend area
            child: SingleChildScrollView(child: _buildPieChartLegends(cards)),
          ),
          // --- End of RenderFlex Fix ---
        ],
      ),
    );
  }
}
