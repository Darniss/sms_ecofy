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

  // --- UPDATED: Requesting multiple permissions ---
  Future<void> _requestAllPermissions() async {
    setState(() {
      _isLoading = true;
    });

    // Request SMS, Contacts, and Phone permissions at the same time
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.contacts,
      Permission.phone,
    ].request();

    // Check if all permissions are granted
    bool allGranted = statuses.values.every((status) => status.isGranted);

    if (allGranted) {
      _proceedToHome();
    } else {
      // Check if any are permanently denied
      bool permanentlyDenied = statuses.values.any(
        (status) => status.isPermanentlyDenied,
      );
      if (permanentlyDenied) {
        _showSettingsDialog();
      } else {
        _showPermissionDeniedDialog();
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _proceedToHome() async {
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
        title: const Text('Permissions Required'),
        content: const Text(
          'SMS, Contacts, and Phone permissions are required for the app to function fully. '
          'Please go to app settings to enable them.',
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
        title: const Text('Permissions Denied'),
        content: const Text(
          'Some permissions were denied. The app may have limited functionality. '
          'You can grant them later from the app settings.',
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
                'To organize your inbox, compose messages, and view contact info, we need a few permissions:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              // --- NEW: Added list of permissions ---
              const SizedBox(height: 24),
              _buildPermissionItem(
                Icons.sms,
                'SMS',
                'To read and organize your messages',
              ),
              const SizedBox(height: 12),
              _buildPermissionItem(
                Icons.contacts,
                'Contacts',
                'To show names and compose new messages',
              ),
              const SizedBox(height: 12),
              _buildPermissionItem(
                Icons.phone,
                'Phone',
                'To let you call a contact from a message',
              ),
              // ------------------------------------
              const Spacer(),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      // --- UPDATED: Calls the new method ---
                      onPressed: _requestAllPermissions,
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
                        'Grant All Permissions',
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
                  'Continue with Limited Mode',
                  style: TextStyle(color: kEcoGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW: Helper widget for the UI ---
  Widget _buildPermissionItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kEcoGreen, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
