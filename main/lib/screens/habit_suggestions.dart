import 'package:flutter/material.dart';
import '../data/habit_templates.dart';
import '../models/habit.dart';

class HabitSuggestionsScreen extends StatefulWidget {
  final String conditionId;
  final String conditionName;

  HabitSuggestionsScreen({
    required this.conditionId,
    required this.conditionName,
  });

  @override
  _HabitSuggestionsScreenState createState() => _HabitSuggestionsScreenState();
}

class _HabitSuggestionsScreenState extends State<HabitSuggestionsScreen> {
  List<Habit> selectedHabits = [];

  @override
  void initState() {
    super.initState();
    selectedHabits = List.from(habitTemplates[widget.conditionId] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sugestii pentru \${widget.conditionName}')),
      body: ListView.builder(
        itemCount: selectedHabits.length,
        itemBuilder: (ctx, i) {
          final habit = selectedHabits[i];
          return CheckboxListTile(
            title: Text(habit.title),
            subtitle: Text(habit.description),
            value: habit.isSelected,
            onChanged: (val) {
              setState(() {
                habit.isSelected = val ?? false;
              });
            },
          );
        },
      ),
    );
  }
}
