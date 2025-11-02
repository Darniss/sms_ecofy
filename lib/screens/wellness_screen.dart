import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import '/providers/reminder_provider.dart';
import '/data/sample_sms_data.dart';
import '/screens/webview_screen.dart';
import '/utils/theme.dart';
import '/core/algorithms.dart' as alogo_;
import '/screens/chat_screen.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key});

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  int _selectedTab = 0; // 0: Summary, 1: e-Paper

  // Helper to extract the first URL from a message body
  String? _extractUrl(String body) {
    final RegExp urlRegex = RegExp(
      r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
      caseSensitive: false,
    );
    final match = urlRegex.firstMatch(body);
    // Ensure we don't just grab a partial URL like "rs."
    if (match != null && match.group(0)!.contains('.')) {
      String url = match.group(0)!;
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }
      return url;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Wellness'), centerTitle: true),
      body: Column(
        children: [
          _buildToggleChips(),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedTab == 0
                ? _buildSummaryTab(provider)
                : _buildEPaperTab(
                    provider.ePaperMessages,
                    provider.allMessages,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleChips() {
    // ... (This method is unchanged)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ToggleButtons(
        isSelected: [_selectedTab == 0, _selectedTab == 1],
        onPressed: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        borderRadius: BorderRadius.circular(20.0),
        selectedColor: Colors.white,
        fillColor: kEcoGreen,
        color: kEcoGreen,
        constraints: BoxConstraints(
          minWidth: (MediaQuery.of(context).size.width - 40) / 2,
          minHeight: 40.0,
        ),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Summary'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('e-Paper'),
          ),
        ],
      ),
    );
  }

  // --- The Summary Tab ---
  Widget _buildSummaryTab(ReminderProvider provider) {
    // ... (This method is unchanged)
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Your Eco-Score',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 20.0,
            percent: provider.ecoScore / 100.0,
            center: Text(
              provider.ecoScore.toStringAsFixed(0),
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            progressColor: kEcoGreen,
            backgroundColor: kEcoGreen.withOpacity(0.1),
            circularStrokeCap: CircularStrokeCap.round,
            footer: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'A high score means you receive more digital transactions and less spam!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildPapersSavedCard(provider.papersSaved),
        ],
      ),
    );
  }

  Widget _buildPapersSavedCard(int papersSaved) {
    // ... (This method is unchanged)
    return Card(
      color: kEcoGreen.withOpacity(0.05),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: kEcoGreen.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, color: kEcoGreen, size: 40),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You saved $papersSaved papers!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kEcoGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By receiving e-bills, you\'re helping the planet.',
                    style: TextStyle(
                      fontSize: 14,
                      color: kEcoGreen.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- The e-Paper Tab ---
  Widget _buildEPaperTab(
    List<SmsMessage> messages,
    List<SmsMessage> allMessages,
  ) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No e-bills or statements found',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final url = _extractUrl(message.body);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: kEcoGreen.withOpacity(0.1),
                  child: Icon(
                    message.transactionType == alogo_.TransactionType.eBill
                        ? Icons.picture_as_pdf
                        : Icons.link,
                    color: kEcoGreen,
                  ),
                ),
                title: Text(
                  message.sender,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  DateFormat.yMMMd().format(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  List<SmsMessage> threadMessages = allMessages
                      .where((m) => m.sender == message.sender)
                      .toList();
                  threadMessages.sort(
                    (a, b) => a.timestamp.compareTo(b.timestamp),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        sender: message.sender,
                        messages: threadMessages,
                        messageToHighlightId: message.id,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                child: Text(
                  message.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              // --- 1. MODIFIED: Divider removed ---
              // const Divider(height: 1, indent: 16, endIndent: 16),

              // --- 2. MODIFIED: Replaced Wrap with Row for equal spacing ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('View'),
                      onPressed: url != null
                          ? () {
                              if (kIsWeb) {
                                launchUrl(
                                  Uri.parse(url),
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        WebViewScreen(url: url),
                                  ),
                                );
                              }
                            }
                          : null,
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.share, size: 16),
                      label: const Text('Share'),
                      onPressed: () {
                        Share.share(message.body);
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.download, size: 16),
                      label: const Text('Download'),
                      onPressed: url != null
                          ? () {
                              launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              // --- END OF MODIFICATIONS ---
            ],
          ),
        );
      },
    );
  }
}
