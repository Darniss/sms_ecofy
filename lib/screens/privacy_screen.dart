import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- NEW IMPORT
import 'dart:math' as math;

import '/providers/reminder_provider.dart';
import '/screens/spam_list_screen.dart';
import '/screens/subscription_manager_screen.dart';
import '/utils/theme.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // --- State for the toggle switch ---
  bool _isNetworkEnabled = true; // This will be our default
  bool _isToggleLoading = true; // <-- NEW: For loading the preference
  static const String _networkToggleKey = 'isNetworkEnabled'; // <-- NEW: Key

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    // --- MODIFIED: Load state from SharedPreferences ---
    _loadToggleState();
  }

  // --- NEW: Function to LOAD the toggle state ---
  Future<void> _loadToggleState() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the saved value. If it's null (first launch), default to 'true'.
    final bool savedState = prefs.getBool(_networkToggleKey) ?? true;

    if (mounted) {
      setState(() {
        _isNetworkEnabled = savedState;
        _isToggleLoading = false; // Done loading
      });

      // Start the animation *after* loading the state
      if (_isNetworkEnabled) {
        _animationController.repeat();
      }
    }
  }

  // --- NEW: Function to SAVE the toggle state ---
  Future<void> _setToggleState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_networkToggleKey, value);

    setState(() {
      _isNetworkEnabled = value;
    });

    if (_isNetworkEnabled) {
      _animationController.repeat(); // Start animation
    } else {
      _animationController.stop(); // Stop animation
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReminderProvider>();
    final privacy = provider.privacySummary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        centerTitle: true,

        // --- MODIFIED: AppBar Toggle (with loading state) ---
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _isToggleLoading
                ? const CupertinoActivityIndicator() // Show loader while loading
                : CupertinoSwitch(
                    value: _isNetworkEnabled,
                    activeColor: kEcoGreen,
                    onChanged: (bool value) {
                      // Save the new state
                      _setToggleState(value);
                    },
                  ),
          ),
        ],
        // --- END MODIFICATION ---
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildNetworkVisualization(),
                  const SizedBox(height: 24),
                  _buildScoreGauges(privacy.pimScore, privacy.trustScore),
                  const SizedBox(height: 16),
                  _buildExplanationCard(),
                  const SizedBox(height: 24),
                  _buildNavCard(
                    context: context,
                    title: 'Subscription Hub',
                    subtitle: 'Manage frequent promo senders',
                    count: provider.subscriptionMessages.length,
                    icon: Icons.unsubscribe,
                    color: kEcoGreen,
                    screen: const SubscriptionManagerScreen(),
                  ),
                  const SizedBox(height: 16),
                  _buildNavCard(
                    context: context,
                    title: 'Spam Reports',
                    subtitle: 'View all detected spam messages',
                    count: provider.spamMessages.length,
                    icon: Icons.shield_outlined,
                    color: kSpamOrange,
                    screen: const SpamListScreen(),
                  ),
                ],
              ),
            ),
    );
  }

  // --- MODIFIED: This widget now swaps its content ---
  Widget _buildNetworkVisualization() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isNetworkEnabled
              ? _buildActiveNetwork() // The spinning animation
              : _buildDisabledNetwork(), // The static "off" message
        ),
      ),
    );
  }

  // --- Helper for the "Network On" state ---
  Widget _buildActiveNetwork() {
    return CustomPaint(
      key: const ValueKey('network_on'), // Key for AnimatedSwitcher
      painter: _NetworkPainter(_animationController),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hub, color: kEcoGreen, size: 40),
            SizedBox(height: 8),
            Text(
              'You are a node',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Your data is decentralized',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper for the "Network Off" state ---
  Widget _buildDisabledNetwork() {
    return Container(
      key: const ValueKey('network_off'), // Key for AnimatedSwitcher
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text(
              'You are not in network',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Decentralized reporting is off',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreGauges(double pimScore, double trustScore) {
    // ... (This widget is unchanged)
    return Row(
      children: [
        Expanded(
          child: _buildScoreCard(
            title: 'Privacy Risk (PIM)',
            score: pimScore,
            percent: pimScore / 100.0,
            color: kSpamOrange,
            footer: 'Lower is better',
            centerText: pimScore.toStringAsFixed(0),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildScoreCard(
            title: 'Message Trust Score',
            score: trustScore,
            percent: trustScore / 100.0,
            color: kEcoGreen,
            footer: 'Higher is better',
            centerText: trustScore.toStringAsFixed(0),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard({
    required String title,
    required double score,
    required double percent,
    required Color color,
    required String footer,
    required String centerText,
  }) {
    // ... (This widget is unchanged)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 8.0,
            percent: percent,
            center: Text(
              centerText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            progressColor: color,
            backgroundColor: color.withOpacity(0.1),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 8),
          Text(
            footer,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --- Explanation Card ---
  Widget _buildExplanationCard() {
    // ... (This widget is unchanged)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What do these scores mean?",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildExplanationRow(
            icon: Icons.shield_outlined,
            color: kEcoGreen,
            title: "Message Trust Score",
            subtitle:
                "A 0-100 score of how trustworthy your messages are. Higher is better (less spam).",
          ),
          const SizedBox(height: 12),
          _buildExplanationRow(
            icon: Icons.lock_person_outlined,
            color: kSpamOrange,
            title: "Privacy Risk (PIM)",
            subtitle:
                "Measures potential data leaks (OTPs, passwords). A higher score means more risk.",
          ),
        ],
      ),
    );
  }

  // --- Helper for the explanation card ---
  Widget _buildExplanationRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    // ... (This widget is unchanged)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
  // --- END NEW WIDGETS ---

  Widget _buildNavCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required int count,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    // ... (This widget is unchanged)
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$count',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }
}

// --- Custom Painter for the Network Visualization ---
// ... (This class is unchanged)
class _NetworkPainter extends CustomPainter {
  final Animation<double> animation;
  _NetworkPainter(this.animation) : super(repaint: animation);

  final Paint linePaint = Paint()
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final Paint nodePaint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    const nodeCount = 8;

    for (int i = 0; i < nodeCount; i++) {
      final double angle =
          (i / nodeCount) * 2 * math.pi + animation.value * 2 * math.pi;
      final nodeCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final double pulse =
          (math.sin(animation.value * 2 * math.pi + i) + 1) / 2;
      final Color color = kEcoGreen.withOpacity(pulse * 0.5 + 0.3);

      linePaint.color = color;
      nodePaint.color = color;

      canvas.drawLine(center, nodeCenter, linePaint);
      canvas.drawCircle(nodeCenter, 4.0, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
