import 'package:flutter/material.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders'), centerTitle: true),
      body: const Center(
        child: Text('Reminders Screen', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
