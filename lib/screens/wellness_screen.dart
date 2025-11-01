import 'package:flutter/material.dart';

class WellnessScreen extends StatelessWidget {
  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wellness'), centerTitle: true),
      body: const Center(
        child: Text('Wellness Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
