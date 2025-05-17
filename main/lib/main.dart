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
  void scheduleReminder() {
    NotificationService.showScheduledNotification(
      hoursFromNow: 1,
      title: '💊 Pastile!',
      body: 'Este timpul să iei medicamentele!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reminder Pastile')),
      body: Center(
        child: ElevatedButton(
          onPressed: scheduleReminder,
          child: Text('Setează reminder în 1 oră'),
        ),
      ),
    );
  }
}
