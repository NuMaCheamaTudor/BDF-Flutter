import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Map<String, int> userXP = {
    'Tu': 0,
    'Tudor': 22,
    'Ana': 18,
    'Vlad': 15,
    'Elena': 12,
  };

  List<String> tasks = [
    'Bea apă dimineața',
    'Fă 10 flotări',
    'Notează 3 lucruri pozitive',
    'Meditează 5 minute',
    'Plimbare de 10 minute'
  ];

  Map<String, bool> checked = {};

  @override
  void initState() {
    super.initState();
    for (var task in tasks) {
      checked[task] = false;
    }
  }

  void updateXP() {
    int count = checked.values.where((v) => v).length;
    setState(() {
      userXP['Tu'] = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedUsers = userXP.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: Text("Clasament + Obiceiuri")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("Bifează obiceiurile tale zilnice:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ...tasks.map((task) => CheckboxListTile(
                title: Text(task),
                value: checked[task],
                onChanged: (val) {
                  setState(() {
                    checked[task] = val ?? false;
                    updateXP();
                  });
                },
              )),
          Divider(thickness: 2),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("🏆 Clasament utilizatori",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sortedUsers.length,
              itemBuilder: (ctx, i) {
                final user = sortedUsers[i];
                return ListTile(
                  leading: Text("#${i + 1}"),
                  title: Text(user.key),
                  trailing: Text("${user.value} XP"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
