import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiTaskClaudeScreen extends StatefulWidget {
  @override
  _AiTaskClaudeScreenState createState() => _AiTaskClaudeScreenState();
}

class _AiTaskClaudeScreenState extends State<AiTaskClaudeScreen> {
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

  Future<void> fetchTasksFromClaude(String problemText) async {
    setState(() {
      _loading = true;
      _tasks = [];
      _checked = {};
    });

    try {
      final apiKey = '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';
      final url = Uri.parse('https://api.anthropic.com/v1/messages');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey,
          'Anthropic-Version': '2023-06-01',
        },
        body: jsonEncode({
          "model": "claude-3-sonnet-20240229",
          "max_tokens": 512,
          "temperature": 0.7,
          "messages": [
            {
              "role": "user",
              "content":
                  "Am această problemă: '$problemText'. Dă-mi 5 obiceiuri utile zilnice, fiecare pe linie separată, fără explicații."
            }
          ]
        }),
      );

      print("RESPONSE STATUS: \ ${response.statusCode}");
      print("RESPONSE BODY: \ ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = (data['content'] is List && data['content'][0]['text'] != null)
            ? data['content'][0]['text']
            : 'Taskurile nu au putut fi extrase.';
        final lines = content
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), ''))
            .toList();

        setState(() {
          _tasks = lines;
          _checked = {for (var task in lines) task: false};
          _loading = false;
        });
      } else {
        setState(() {
          _tasks = ['Eroare: \ ${response.statusCode}'];
          _loading = false;
        });
      }
    } catch (e, stacktrace) {
      print("EROARE CATCH: \ $e");
      print(stacktrace);
      setState(() {
        _tasks = ['A apărut o eroare neașteptată.'];
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
      appBar: AppBar(title: Text('Claude Habit AI + Clasament')),
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
                  : () => fetchTasksFromClaude(_controller.text.trim()),
              child: Text("Generează obiceiuri cu Claude"),
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
                    leading: Text("#\ ${i + 1}"),
                    title: Text(user['name']),
                    trailing: Text("\ ${user['xp']} XP"),
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
