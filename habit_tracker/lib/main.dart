import 'package:flutter/material.dart';
import 'screens/select_condition.dart';
import 'screens/how_you_feel.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/combined_habit_social_screen.dart';
import 'screens/ai_task_social_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker Mental Health',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
     home:AiTaskClaudeScreen(),
    );
  }
}
