import 'package:flutter/material.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder Pastile',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      await NotificationService.scheduleReminderAtTime(picked.hour, picked.minute);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder setat la ${picked.format(context)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminder Pastile')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => pickTime(context),
          child: const Text('Setează reminder'),
        ),
      ),
    );
  }
}
