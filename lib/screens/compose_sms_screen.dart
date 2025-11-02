import '/utils/theme.dart';
import 'package:flutter/material.dart';
import '/config/env_config.dart'; // You need this
import '/services/sms_service.dart'; // You will create this
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
class ComposeSmsScreen extends StatefulWidget {
  const ComposeSmsScreen({super.key});

  @override
  State<ComposeSmsScreen> createState() => _ComposeSmsScreenState();
}

class _ComposeSmsScreenState extends State<ComposeSmsScreen> {
  final _toController = TextEditingController();
  final _bodyController = TextEditingController();
  final _smsService = SmsService();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _toController.addListener(_updateSendButton);
    _bodyController.addListener(_updateSendButton);
  }

  @override
  void dispose() {
    _toController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _updateSendButton() {
    setState(() {
      _canSend =
          _toController.text.isNotEmpty && _bodyController.text.isNotEmpty;
    });
  }

  Future<void> _sendMessage() async {
    if (!_canSend) return;

    final recipients = _toController.text.split(',');
    final body = _bodyController.text;

    bool success = await _smsService.sendSms(recipients, body);

    if (success && mounted) {
      if (EnvironmentConfig.isTestMode) {
        // Test Mode: Just pop
        Navigator.of(context).pop();
      } else {
        // Prod Mode: Navigate to the chat screen
        // This is complex: you need to find the thread or create a new one
        // and then navigate. For now, we'll just pop.
        Navigator.of(context).pop();
        // In a real app:
        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //   builder: (context) => ChatScreen(...)
        // ));
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Message')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _toController,
              decoration: const InputDecoration(labelText: 'To:'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 10,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _canSend ? _sendMessage : null,
        backgroundColor: _canSend ? kEcoGreen : Colors.grey,
        child: const Icon(Icons.send),
      ),
    );
  }
}
