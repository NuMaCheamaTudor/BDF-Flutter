import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'reminder_page.dart'; // HomeScreen e aici
import 'get_help.dart';
import 'dailychallenge.dart';
import 'onboarding_screen.dart';

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
      home: OnboardingScreen(), 
    );
  }
}
class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrare verticală
          children: [
            ElevatedButton(
              child: const Text('Set a timer!'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReminderPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Change Your Life'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReminderPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Daily Challenge'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DailyChallenge()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Get Help'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GetHelp()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

