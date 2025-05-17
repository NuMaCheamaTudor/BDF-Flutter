import 'package:flutter/material.dart';
import 'reminder_page.dart';
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
      home: SplashScreen(),
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text('Your Dashboard'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          children: [
            _buildDashboardTile(
              context,
              icon: Icons.timer_outlined,
              label: 'Set a timer',
              color: Colors.deepPurple,
              onTap: () => Navigator.push(context, _createRoute(ReminderPage())),
            ),
            _buildDashboardTile(
              context,
              icon: Icons.auto_awesome,
              label: 'Change Your Life',
              color: Colors.orange,
              onTap: () => Navigator.push(context, _createRoute(ReminderPage())),
            ),
            _buildDashboardTile(
              context,
              icon: Icons.flash_on,
              label: 'Daily Challenge',
              color: Colors.pinkAccent,
              onTap: () => Navigator.push(context, _createRoute(DailyChallenge())),
            ),
            _buildDashboardTile(
              context,
              icon: Icons.group,
              label: 'Get Help',
              color: Colors.teal,
              onTap: () => Navigator.push(context, _createRoute(UltimateSocialHabitScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              )
            ],
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
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
        final fade = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fade),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}