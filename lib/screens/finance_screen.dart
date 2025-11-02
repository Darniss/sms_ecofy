import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/providers/reminder_provider.dart';
import '/core/algorithms.dart' as alogo_;
import '/utils/theme.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  // --- State for the show/hide toggle ---
  bool _isObscured = true;
  bool _isToggleLoading = true;
  static const String _obscureKey = 'isFinanceObscured';

  // For formatting currency
  final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _loadToggleState();
  }

  Future<void> _loadToggleState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isObscured = prefs.getBool(_obscureKey) ?? true;
      _isToggleLoading = false;
    });
  }

  Future<void> _setToggleState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_obscureKey, value);
    setState(() {
      _isObscured = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the data from the provider
    final provider = context.watch<ReminderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance'),
        centerTitle: true,
        actions: [
          // The Show/Hide Toggle Button
          _isToggleLoading
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => _setToggleState(!_isObscured),
                ),
          const SizedBox(width: 16),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // --- 1. NEW DISCLAIMER CARD ---
                _buildDisclaimerCard(),
                const SizedBox(height: 24),
                // --- END NEW ---

                // --- Accounts Section ---
                Text(
                  'Bank Accounts',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (provider.bankAccounts.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    itemCount: provider.bankAccounts.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // --- 2. USING MODIFIED CARD ---
                      return _buildAccountCard(provider.bankAccounts[index]);
                    },
                  ),

                // --- Credit Cards Section ---
                const SizedBox(height: 24),
                Text(
                  'Credit Cards',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (provider.creditCards.isEmpty)
                  _buildEmptyState()
                else
                  ListView.builder(
                    itemCount: provider.creditCards.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // --- 2. USING MODIFIED CARD ---
                      return _buildAccountCard(provider.creditCards[index]);
                    },
                  ),
              ],
            ),
    );
  }

  // --- NEW WIDGET: Disclaimer Card ---
  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Balance powered from SMS. Actual may vary.',
              style: TextStyle(color: Colors.amber[900], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
  // --- END NEW WIDGET ---

  // --- Helper for empty states ---
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'No accounts found in SMS.',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  // --- MODIFIED WIDGET: Smaller, compact card ---
  Widget _buildAccountCard(alogo_.FinancialAccount account) {
    final isBank = account.type == alogo_.TransactionType.bank;
    final color = isBank ? kEcoGreen : kPimPurple;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        // --- 1. LEADING ICON ---
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            isBank ? Icons.account_balance : Icons.credit_card,
            color: color,
          ),
        ),

        // --- 2. TITLE & SUBTITLE (Left Corner) ---
        title: Text(
          account.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(account.number, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              'Last updated: ${DateFormat.MMMd().add_jm().format(account.lastUpdated)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),

        // --- 3. TRAILING BALANCE (Right Corner) ---
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _isObscured
                  ? '₹ ••••'
                  : currencyFormatter.format(account.balance),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(
              isBank ? 'Available' : 'Total Due',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  // --- END MODIFICATION ---
}
