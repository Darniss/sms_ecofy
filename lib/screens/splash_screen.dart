import 'package:flutter/material.dart';
import 'dart:async';
import '/screens/permission_screen.dart';
import '/utils/storage_service.dart';
import '/utils/theme.dart';
import '/widgets/app_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    // Wait for 2 seconds on splash
    await Future.delayed(const Duration(seconds: 2));

    final bool isFirstLaunch = await _storageService.isFirstLaunch();

    if (mounted) {
      if (isFirstLaunch) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PermissionScreen()),
        );
      } else {
        // Navigate to the new MainNavigationScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kEcoGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌿', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            Text(
              'SMS Ecofy',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
