import 'package:flutter/material.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finance'), centerTitle: true),
      body: const Center(
        child: Text('Finance Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
