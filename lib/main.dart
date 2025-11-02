import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/splash_screen.dart';
import 'services/sms_service.dart';
import '/utils/theme.dart';
import '/providers/reminder_provider.dart';

void main() async {
  // Ensure bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // We can still initialize prefs here for other services if needed
  await SharedPreferences.getInstance();

  // --- THIS IS THE MODIFICATION ---

  // We are replacing 'ChangeNotifierProvider' with 'MultiProvider'
  // to allow us to provide BOTH ThemeProvider and ReminderProvider.
  runApp(
    MultiProvider(
      providers: [
        // Your existing provider for Theme (Light/Dark mode)
        ChangeNotifierProvider(create: (context) => ThemeProvider()),

        // --- NEW ---
        // Your new provider for Reminders.
        // We call '..fetchAndParseReminders()' immediately
        // so the app starts loading reminders right away.
        ChangeNotifierProvider(
          create: (context) => ReminderProvider()..fetchAndParseReminders(),
        ),
        // --- END NEW ---
      ],
      child: const SmsEcofyApp(), // Your app widget
    ),
  );
  // --- END OF MODIFICATION ---
}

class SmsEcofyApp extends StatelessWidget {
  const SmsEcofyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consume the ThemeProvider
    // This part does NOT need to change. It still works perfectly.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'SMS Ecofy',
          debugShowCheckedModeBanner: false,

          // Use provider for theme settings
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,

          home: const SplashScreen(),
        );
      },
    );
  }
}
