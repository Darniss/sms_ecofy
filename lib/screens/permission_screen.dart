import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '/utils/storage_service.dart';
import '/utils/theme.dart';
import '/widgets/app_navigation.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final StorageService _storageService = StorageService();
  bool _isLoading = false;

  Future<void> _requestSmsPermission() async {
    setState(() {
      _isLoading = true;
    });

    var status = await Permission.sms.request();

    if (status.isGranted) {
      _proceedToHome();
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog();
    } else {
      _showPermissionDeniedDialog();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _proceedToHome() async {
    // Mark first launch as done
    await _storageService.setFirstLaunchDone();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'SMS permission is permanently denied. Please go to app settings to enable it.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'SMS permission is required for the app to read your messages. Please grant permission to continue.',
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '🌿',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to SMS Ecofy',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'To help you organize your inbox, we need permission to read your SMS messages.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),

              // --- Removed Test / Production Toggle ---
              const Spacer(),

              // --- Action Button ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _requestSmsPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kEcoGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Grant Permission',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _proceedToHome,
                child: const Text(
                  'Continue without Permission (Limited Mode)',
                  style: TextStyle(color: kEcoGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
