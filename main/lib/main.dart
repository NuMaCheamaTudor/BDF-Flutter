import 'package:flutter/material.dart';
import 'reminder_page.dart'; // ReminderPage() e HomeScreen
import 'get_help.dart';
import 'dailychallenge.dart';
import 'ultimate_social_habit_screen (1).dart';
import 'notification_service.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reminder Pastile',
      home: SplashScreen(), // pornim cu splash
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            _buildButtonCard(
              context,
              icon: Icons.timer_outlined,
              label: 'Set a timer!',
              onPressed: () {
                Navigator.push(context, _createRoute(ReminderPage()));
              },
            ),
            _buildButtonCard(
              context,
              icon: Icons.auto_awesome,
              label: 'Change Your Life',
              onPressed: () {
                Navigator.push(context, _createRoute(ReminderPage()));
              },
            ),
            _buildButtonCard(
              context,
              icon: Icons.flash_on,
              label: 'Daily Challenge',
              onPressed: () {
                Navigator.push(context, _createRoute(DailyChallenge()));
              },
            ),
            _buildButtonCard(
              context,
              icon: Icons.group,
              label: 'Get Help',
              onPressed: () {
                Navigator.push(context, _createRoute(UltimateSocialHabitScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
        highlightColor: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48, color: Theme.of(context).primaryColor),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.1);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        final fade = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fade),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
