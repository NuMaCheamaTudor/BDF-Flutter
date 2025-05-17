import 'package:flutter/material.dart';
import 'notification_service.dart';

class ReminderPage extends StatelessWidget {
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
      appBar: AppBar(title: const Text('Reminder')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => pickTime(context),
          child: const Text('Set Reminder'),
        ),
      ),
    );
  }
}
