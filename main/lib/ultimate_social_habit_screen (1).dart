import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UltimateSocialHabitScreen extends StatefulWidget {
  @override
  _UltimateSocialHabitScreenState createState() =>
      _UltimateSocialHabitScreenState();
}

class _UltimateSocialHabitScreenState
    extends State<UltimateSocialHabitScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _tasks = [];
  Map<String, bool> _checked = {};
  bool _loading = false;

  String _username = "Tu";
  String _avatar = "🧠";
  final String _dailyChallenge =
      "Scrie 3 lucruri pentru care ești recunoscător";

  final List<Map<String, dynamic>> friends = [
    {'name': 'Tudor', 'xp': 3},
    {'name': 'Ana', 'xp': 4},
    {'name': 'Vlad', 'xp': 2},
    {'name': 'Elena', 'xp': 1},
  ];

  List<String> socialFeed = [];

  void _updateXP() {
    final done = _checked.values.where((v) => v).length;
    final xp = done + (_dailyChallengeCompleted ? 2 : 0);
    setState(() {
      socialFeed.add("$_username a bifat $done taskuri și a câștigat $xp XP 🎉");
    });
  }

  bool get _dailyChallengeCompleted {
    return _checked[_dailyChallenge] ?? false;
  }

  Future<void> getTasksFromFlask(String problemText) async {
    setState(() {
      _loading = true;
      _tasks = [];
      _checked = {};
    });

    try {
      final url = Uri.parse("http://192.168.1.10:5000/generate_tasks");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"problem": problemText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lines = List<String>.from(data["tasks"]);

        setState(() {
          _tasks = [_dailyChallenge, ...lines];
          _checked = {for (var task in _tasks) task: false};
          _loading = false;
        });
      } else {
        setState(() {
          _tasks = ['Eroare: ${response.statusCode}'];
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _tasks = ['A apărut o eroare de rețea.'];
        _loading = false;
      });
    }
  }

  Widget _buildTaskTile(String task) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.white, Colors.purple.shade50]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.deepPurple.withOpacity(0.15),
              blurRadius: 10,
              offset: Offset(0, 4))
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      child: CheckboxListTile(
        title: Text(task, style: TextStyle(fontSize: 16)),
        value: _checked[task] ?? false,
        onChanged: (val) {
          setState(() {
            _checked[task] = val ?? false;
            _updateXP();
          });
        },
      ),
    );
  }

  Widget _buildBadge(String title, IconData icon, bool earned) {
    return Column(
      children: [
        Icon(icon, size: 36, color: earned ? Colors.amber : Colors.grey[300]),
        SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedFriends = [
      {
        'name': _username,
        'xp': _checked.values.where((v) => v).length +
            (_dailyChallengeCompleted ? 2 : 0)
      },
      ...friends
    ]..sort((a, b) => b['xp'].compareTo(a['xp']));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('🌌 Habit Universe'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _avatar = value),
            itemBuilder: (ctx) => ['🧠', '🐸', '🐱', '🧘', '🐺']
                .map((e) =>
                    PopupMenuItem(value: e, child: Text("Avatar $e")))
                .toList(),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffe0c3fc), Color(0xff8ec5fc)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 100.0, left: 12.0, right: 12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("$_avatar", style: TextStyle(fontSize: 40)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: "Ce problemă ai?",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () => getTasksFromFlask(_controller.text),
                      child: Text("Generează"),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                if (_loading)
                  Center(child: CircularProgressIndicator()),
                if (!_loading && _tasks.isNotEmpty)
                  Expanded(
                    child: ListView(
                      children: _tasks.map(_buildTaskTile).toList(),
                    ),
                  ),
                const Divider(),
                Text("🏅 Badge-uri",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBadge("Focus x5", Icons.star, _checked.length >= 5),
                    _buildBadge("Challenge OK", Icons.check_circle,
                        _dailyChallengeCompleted),
                    _buildBadge("AI Hacker", Icons.bolt,
                        _controller.text.isNotEmpty),
                  ],
                ),
                const Divider(),
                Text("📢 Activitate prieteni"),
                ...socialFeed.reversed
                    .take(3)
                    .map((msg) => ListTile(title: Text(msg))),
                const Divider(),
                Text("🏆 Clasament"),
                ...sortedFriends.map((user) => ListTile(
                      leading:
                          Text("#${sortedFriends.indexOf(user) + 1}"),
                      title: Text(user['name']),
                      trailing: Text("${user['xp']} XP"),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
