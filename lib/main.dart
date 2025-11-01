import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/splash_screen.dart';
import '/providers/sms_provider.dart';
import '/utils/theme.dart';

void main() async {
  // Ensure bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // We can still initialize prefs here for other services if needed
  await SharedPreferences.getInstance();

  runApp(
    ChangeNotifierProvider(
      // FIX 2: Changed to use the no-argument constructor
      create: (context) => ThemeProvider(),
      child: const SmsEcofyApp(),
    ),
  );
}

class SmsEcofyApp extends StatelessWidget {
  const SmsEcofyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consume the ThemeProvider
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'SMS Ecofy',
          debugShowCheckedModeBanner: false,

          // Use provider for theme settings
          // FIX 1: Accessed lightTheme and darkTheme directly
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,

          home: const SplashScreen(),
        );
      },
    );
  }
}
