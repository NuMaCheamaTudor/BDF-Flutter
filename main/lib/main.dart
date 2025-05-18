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

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reminder Pastile',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreenWrapper(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class SplashScreenWrapper extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const SplashScreenWrapper({required this.toggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return SplashScreen(); // Replace with your navigation logic
  }
}

class StartPage extends StatelessWidget {
  final VoidCallback? toggleTheme;
  final bool isDarkMode;

  const StartPage({this.toggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text('Your Dashboard'),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: toggleTheme,
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: 0.1,
              duration: const Duration(seconds: 1),
              child: Image.asset(
                'assets/bg_glow.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1,
              ),
              children: [
                _buildDashboardTile(context, Icons.timer_outlined, 'Set a timer', Colors.deepPurple, () => Navigator.push(context, _createRoute(ReminderPage()))),
                _buildDashboardTile(context, Icons.auto_awesome, 'Change Your Life', Colors.orange, () => Navigator.push(context, _createRoute(ReminderPage()))),
                _buildDashboardTile(context, Icons.flash_on, 'Daily Challenge', Colors.pinkAccent, () => Navigator.push(context, _createRoute(DailyChallenge()))),
                _buildDashboardTile(context, Icons.group, 'Get Help', Colors.teal, () => Navigator.push(context, _createRoute(UltimateSocialHabitScreen()))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.6), color.withOpacity(0.9)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
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
