import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/utils/app_icons.dart';
import '/utils/storage_service.dart';
import '/utils/theme.dart';

// --- Model for Card Data ---
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

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

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
                              // Show a snackbar or message
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
                      // This is a safeguard, but the UI should prevent this.
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
        return _buildSummaryCard(card);
      },
    );
  }

  Widget _buildSummaryCard(SummaryCardData card) {
    return Container(
      decoration: BoxDecoration(
        color: card.tint,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(card.icon, color: card.color, size: 28),
            const SizedBox(height: 8),
            Text(
              '${card.value} ${card.title}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                // --- FIX: Use Theme.of(context) ---
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sections: cards.map((card) {
            return PieChartSectionData(
              color: card.color,
              value: card.value.toDouble(),
              title: '${(card.value / total * 100).toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}
