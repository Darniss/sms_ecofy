import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '/providers/reminder_provider.dart'; 

import '/screens/home_screen.dart';
import '/screens/finance_screen.dart';
import '/screens/reminder_screen.dart';
import '/screens/wellness_screen.dart';
import '/screens/privacy_screen.dart';
import '/utils/app_icons.dart';
import '/utils/theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    FinanceScreen(),
    ReminderScreen(),
    WellnessScreen(),
    PrivacyScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- NEW: Watch the provider for changes ---
    // This line listens to your ReminderProvider.
    // When the count changes, this widget will rebuild.
    final int reminderCount = context
        .watch<ReminderProvider>()
        .upcomingReminderCount;
    // --- END NEW ---

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

      // --- MODIFIED: The FloatingActionButton ---
      floatingActionButton: FloatingActionButton(
        heroTag: 'mainNavFab',
        onPressed: () => _onItemTapped(2),
        backgroundColor: kEcoGreen, // Use theme color
        foregroundColor: Colors.white, // Use theme color
        // --- NEW: Wrap the Icon in a Stack to add a badge ---
        child: Stack(
          clipBehavior: Clip.none, // Allows the badge to be outside the FAB
          children: [
            Icon(
              _selectedIndex == 2
                  ? AppIcons.reminder
                  : AppIcons.reminderOutlined,
              size: 30,
            ),

            // --- NEW: This is the Badge ---
            if (reminderCount > 0)
              Positioned(
                top: -8, // Adjust position as needed
                right: -8, // Adjust position as needed
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '$reminderCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            // --- END NEW ---
          ],
        ),
        // --- END MODIFICATION ---
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- This BottomAppBar is UNCHANGED ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 65.0,
          child: Row(
            children: <Widget>[
              Expanded(
                child: _buildNavItem(
                  icon: AppIcons.homeOutlined,
                  activeIcon: AppIcons.home,
                  label: 'Home',
                  index: 0,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: AppIcons.financeOutlined,
                  activeIcon: AppIcons.finance,
                  label: 'Finance',
                  index: 1,
                ),
              ),
              const SizedBox(width: 72.0), // The gap
              Expanded(
                child: _buildNavItem(
                  icon: AppIcons.wellnessOutlined,
                  activeIcon: AppIcons.wellness,
                  label: 'Wellness',
                  index: 3,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: AppIcons.privacyOutlined,
                  activeIcon: AppIcons.privacy,
                  label: 'Privacy',
                  index: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- This helper method is UNCHANGED ---
  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _selectedIndex == index;
    final Color activeColor = kEcoGreen;
    final Color inactiveColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    return MaterialButton(
      minWidth: 40,
      onPressed: () => _onItemTapped(index),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
