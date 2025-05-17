import 'package:flutter/material.dart';

class CombinedHabitSocialScreen extends StatefulWidget {
  @override
  _CombinedHabitSocialScreenState createState() =>
      _CombinedHabitSocialScreenState();
}

class _CombinedHabitSocialScreenState extends State<CombinedHabitSocialScreen> {
  final Map<String, List<String>> taskMap = {
    'Anxietate': [
      'Respiră adânc 5 minute',
      'Scrie un gând pozitiv',
      'Fă o plimbare de 10 minute',
      'Ascultă muzică relaxantă',
      'Evită social media 1 oră'
    ],
    'Depresie': [
      'Deschide geamul și respiră aer proaspăt',
      'Sună un prieten',
      'Scrie 3 lucruri pentru care ești recunoscător',
      'Fă un duș și schimbă hainele',
      'Notează 1 obiectiv mic pentru azi'
    ],
    'ADHD': [
      'Setează un timer de 15 min pentru focus',
      'Curăță spațiul de lucru 5 min',
      'Fă o pauză activă (stretching)',
      'Scrie lista de taskuri pe azi',
      'Bea un pahar cu apă'
    ],
    'Oboseală mentală': [
      'Ia o pauză de ecran 20 min',
      'Bea apă',
      'Închide ochii 5 min',
      'Ascultă o melodie calmă',
      'Spală fața cu apă rece'
    ]
  };

  final List<Map<String, dynamic>> friends = [
    {'name': 'Tu', 'xp': 0},
    {'name': 'Tudor', 'xp': 3},
    {'name': 'Ana', 'xp': 4},
    {'name': 'Vlad', 'xp': 2},
    {'name': 'Elena', 'xp': 1},
  ];

  String selectedCondition = 'Anxietate';
  Map<String, bool> checkedTasks = {};

  @override
  void initState() {
    super.initState();
    _generateTasksForCondition();
  }

  void _generateTasksForCondition() {
    checkedTasks = {
      for (var task in taskMap[selectedCondition]!) task: false,
    };
    _updateUserXP();
  }

  void _updateUserXP() {
    final done = checkedTasks.values.where((v) => v).length;
    setState(() {
      friends[0]['xp'] = done; // Update XP for "Tu"
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedFriends = [...friends]
      ..sort((a, b) => b['xp'].compareTo(a['xp']));

    return Scaffold(
      appBar: AppBar(title: Text("Habit Challenge Social")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedCondition,
              items: taskMap.keys
                  .map((key) =>
                      DropdownMenuItem(value: key, child: Text(key)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCondition = value;
                    _generateTasksForCondition();
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Ce problemă ai?',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text("Taskuri recomandate:", style: TextStyle(fontSize: 18)),
            ...checkedTasks.keys.map((task) => CheckboxListTile(
                  title: Text(task),
                  value: checkedTasks[task],
                  onChanged: (val) {
                    setState(() {
                      checkedTasks[task] = val ?? false;
                      _updateUserXP();
                    });
                  },
                )),
            Divider(thickness: 2),
            SizedBox(height: 12),
            Text("🏆 Clasament prieteni", style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: sortedFriends.length,
                itemBuilder: (ctx, i) {
                  final user = sortedFriends[i];
                  return ListTile(
                    leading: Text("#${i + 1}"),
                    title: Text(user['name']),
                    trailing: Text("${user['xp']} XP"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
