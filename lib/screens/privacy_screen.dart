import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy'), centerTitle: true),
      body: const Center(
        child: Text('Privacy Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
