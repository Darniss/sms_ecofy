import 'package:flutter/material.dart';
import '/screens/home_screen.dart';
import '/screens/finance_screen.dart';
import '/screens/reminder_screen.dart';
import '/screens/wellness_screen.dart';
import '/screens/privacy_screen.dart';
import '/utils/app_icons.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(AppIcons.homeOutlined),
            activeIcon: Icon(AppIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.financeOutlined),
            activeIcon: Icon(AppIcons.finance),
            label: 'Finance',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.reminderOutlined),
            activeIcon: Icon(AppIcons.reminder),
            label: 'Reminder',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.wellnessOutlined),
            activeIcon: Icon(AppIcons.wellness),
            label: 'Wellness',
          ),
          BottomNavigationBarItem(
            icon: Icon(AppIcons.privacyOutlined),
            activeIcon: Icon(AppIcons.privacy),
            label: 'Privacy',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
