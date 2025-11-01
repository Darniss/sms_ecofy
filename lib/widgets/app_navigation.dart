import 'package:flutter/material.dart';
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
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),

      // --- FIX: Removed Container with gradient. Using theme-based FAB ---
      floatingActionButton: FloatingActionButton(
        heroTag: 'mainNavFab',
        onPressed: () => _onItemTapped(2),
        backgroundColor: kEcoGreen, // Use theme color
        foregroundColor: Colors.white, // Use theme color
        child: Icon(
          _selectedIndex == 2 ? AppIcons.reminder : AppIcons.reminderOutlined,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- NEW: Bottom App Bar with Notch ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 65.0, // Define a consistent height
          // --- FIX: Using a single Row with Expanded for stable alignment ---
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
              // --- This SizedBox creates the stable gap for the notch ---
              // A standard FAB is 56px, notchMargin is 8px*2 = 16px.
              // 56 + 16 = 72px.
              const SizedBox(width: 72.0),
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

  // --- UPDATED: Helper widget for navigation items ---
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

    // --- FIX: Using MaterialButton for highlight box and shape ---
    return MaterialButton(
      minWidth: 40,
      onPressed: () => _onItemTapped(index),
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Padding for box
      // --- This creates the "box" highlight ---
      color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded box
      ),
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
