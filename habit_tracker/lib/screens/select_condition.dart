import 'package:flutter/material.dart';
import '../models/condition.dart';
import 'habit_suggestions.dart';

class SelectConditionScreen extends StatelessWidget {
  final List<Condition> conditions = [
    Condition(id: 'adhd', name: 'ADHD', emoji: '⚡'),
    Condition(id: 'depresie', name: 'Depresie', emoji: '🌧️'),
    Condition(id: 'anxietate', name: 'Anxietate', emoji: '💭'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Selectează afecțiunea')),
      body: ListView.builder(
        itemCount: conditions.length,
        itemBuilder: (ctx, i) {
          final c = conditions[i];
          return ListTile(
            title: Text('\${c.emoji} \${c.name}'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HabitSuggestionsScreen(
                  conditionId: c.id,
                  conditionName: c.name,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
