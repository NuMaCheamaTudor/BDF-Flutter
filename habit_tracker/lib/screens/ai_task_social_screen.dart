import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiTaskSocialScreen extends StatefulWidget {
  @override
  _AiTaskSocialScreenState createState() => _AiTaskSocialScreenState();
}

class _AiTaskSocialScreenState extends State<AiTaskSocialScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _tasks = [];
  Map<String, bool> _checked = {};
  bool _loading = false;

  final List<Map<String, dynamic>> friends = [
    {'name': 'Tu', 'xp': 0},
    {'name': 'Tudor', 'xp': 3},
    {'name': 'Ana', 'xp': 4},
    {'name': 'Vlad', 'xp': 2},
    {'name': 'Elena', 'xp': 1},
  ];

  Future<void> fetchTasksFromRapidAPI(String problemText) async {
    setState(() {
      _loading = true;
      _tasks = [];
      _checked = {};
    });

    final apiKey = '';
    final url = Uri.parse('https://chatgpt-42.p.rapidapi.com/conversationgpt4');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': 'chatgpt-42.p.rapidapi.com',
      },
      body: jsonEncode({
        "messages": [
          {
            "role": "user",
            "content":
                "Am această problemă: '$problemText'. Dă-mi 5 obiceiuri utile zilnice, fiecare pe linie separată, fără explicații."
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['result'] ?? "";
      final lines = content
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^\d+\.?\s*'), ''))
          .toList();

      setState(() {
        _tasks = lines;
        _checked = {for (var task in lines) task: false};
        _loading = false;
      });
    } else {
      setState(() {
        _tasks = ['Eroare: ${response.statusCode}'];
        _loading = false;
      });
    }
  }

  void _updateXP() {
    final done = _checked.values.where((v) => v).length;
    setState(() {
      friends[0]['xp'] = done;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedFriends = [...friends]
      ..sort((a, b) => b['xp'].compareTo(a['xp']));

    return Scaffold(
      appBar: AppBar(title: Text('Habit AI + Clasament')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Ce problemă ai?',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () => fetchTasksFromRapidAPI(_controller.text.trim()),
              child: Text("Generează obiceiuri cu AI"),
            ),
            SizedBox(height: 20),
            if (_loading) CircularProgressIndicator(),
            if (!_loading && _tasks.isNotEmpty)
              Expanded(
                child: ListView(
                  children: _tasks.map((task) {
                    return CheckboxListTile(
                      title: Text(task),
                      value: _checked[task] ?? false,
                      onChanged: (val) {
                        setState(() {
                          _checked[task] = val ?? false;
                          _updateXP();
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            Divider(),
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
