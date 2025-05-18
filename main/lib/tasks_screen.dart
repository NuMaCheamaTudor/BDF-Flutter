import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  final List<String> initialTasks;
  final Map<String, bool> initialChecked;
  final Map<String, List<String>> initialReactions;
  final void Function(Map<String, bool>)? onTasksUpdated;

  const TasksScreen({
    Key? key,
    required this.initialTasks,
    required this.initialChecked,
    required this.initialReactions,
    this.onTasksUpdated,
  }) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late Map<String, bool> checked;

  @override
  void initState() {
    super.initState();
    checked = Map<String, bool>.from(widget.initialChecked);
  }

  void _onCheckboxChanged(String task, bool? value) {
    setState(() {
      checked[task] = value ?? false;
    });
    if (widget.onTasksUpdated != null) {
      widget.onTasksUpdated!(checked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activități")),
      body: ListView(
        children: widget.initialTasks.map((task) {
          return CheckboxListTile(
            title: Text(task),
            value: checked[task] ?? false,
            onChanged: (val) => _onCheckboxChanged(task, val),
          );
        }).toList(),
      ),
    );
  }
}
