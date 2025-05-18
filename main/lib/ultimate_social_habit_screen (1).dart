import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'tasks_screen.dart';

class UltimateSocialHabitScreen extends StatefulWidget {
  @override
  _UltimateSocialHabitScreenState createState() => _UltimateSocialHabitScreenState();
}

class _UltimateSocialHabitScreenState extends State<UltimateSocialHabitScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _tasks = [];
  Map<String, bool> _checked = {};
  Map<String, List<String>> _reactions = {};
  bool _loading = false;

  String _username = "Tu";
  String _avatar = "🧠";
  final String _dailyChallenge = "Scrie 3 lucruri pentru care ești recunoscător";

  List<Map<String, dynamic>> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _initUserAndData();
  }

  Future<void> _initUserAndData() async {
    await _createUser(_username);
    await _loadSavedData();
    await _loadLeaderboard();
  }

  // ==== API calls ====

  Future<bool> _createUser(String username) async {
    final url = Uri.parse("http://192.168.1.128:5001/create_user");
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}));
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print("Eroare la create_user: ${response.body}");
      return false;
    }
  }

  Future<int> _getUserXp(String username) async {
    final url = Uri.parse("http://192.168.1.128:5001/get_xp/$username");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['xp'] as int;
    } else {
      print("Eroare la get_xp: ${response.body}");
      return 0;
    }
  }

  Future<bool> _incrementXp(String username, int amount) async {
    final url = Uri.parse("http://192.168.1.120:5001/increment_xp");
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'amount': amount}));
    if (response.statusCode == 200) {
      await _loadLeaderboard(); // update clasament după incrementare
      return true;
    } else {
      print("Eroare la increment_xp: ${response.body}");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> _getLeaderboard() async {
    final url = Uri.parse("http://192.168.1.128:5001/leaderboard");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print("Eroare la leaderboard: ${response.body}");
      return [];
    }
  }

  Future<void> _loadLeaderboard() async {
    final lb = await _getLeaderboard();
    setState(() {
      _leaderboard = lb;
    });
  }

  // ==== Shared Preferences ====

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTasks = prefs.getStringList('tasks') ?? [];
    final savedCheckedRaw = prefs.getString('checked');
    final savedReactionsRaw = prefs.getString('reactions');

    Map<String, bool> checked = {};
    if (savedCheckedRaw != null) {
      final decoded = jsonDecode(savedCheckedRaw) as Map<String, dynamic>;
      checked = decoded.map((k, v) => MapEntry(k, v as bool));
    }

    setState(() {
      _tasks = savedTasks;
      _checked = checked;
      _reactions = savedReactionsRaw != null
          ? (jsonDecode(savedReactionsRaw) as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, List<String>.from(v)))
          : {};
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', _tasks);
    await prefs.setString('checked', jsonEncode(_checked));
    await prefs.setString('reactions', jsonEncode(_reactions));
  }

  // ==== Main logic ====

  bool get _dailyChallengeCompleted => _checked[_dailyChallenge] ?? false;

  Future<void> getTasksFromFlask(String problemText) async {
    setState(() {
      _loading = true;
      _tasks = [];
      _checked = {};
      _reactions = {};
    });

    try {
      final url = Uri.parse("http://192.168.1.128:5001/plan");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final raw = data["response"] as String;

        final start = raw.indexOf("text='") + 6;
        final end = raw.indexOf("', type='text'");
        if (start >= 6 && end > start) {
          String extractedText = raw.substring(start, end);
          final lines = extractedText
              .split(';')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList();

          setState(() {
            _tasks = [_dailyChallenge, ...lines];
            _checked = {for (var task in _tasks) task: false};
            _reactions = {for (var task in _tasks) task: []};
            _loading = false;
          });

          await _saveData();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TasksScreen(
                initialTasks: _tasks,
                initialChecked: _checked,
                initialReactions: _reactions,
                onTasksUpdated: _onTasksUpdated, // callback când user bifează taskuri
              ),
            ),
          ).then((_) => _loadSavedData());
        } else {
          setState(() {
            _tasks = ['Eroare la extragerea textului din răspuns.'];
            _loading = false;
          });
        }
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

  // Apelat când user bifează task-uri în TasksScreen (trimis prin callback)
  Future<void> _onTasksUpdated(Map<String, bool> updatedChecked) async {
    setState(() {
      _checked = updatedChecked;
    });
    await _saveData();

    // Calculăm câte taskuri noi au fost bifate
    final completedCount = _checked.values.where((v) => v).length + (_dailyChallengeCompleted ? 2 : 0);
    await _incrementXp(_username, completedCount);
  }

  @override
  Widget build(BuildContext context) {
    final xp = _checked.values.where((v) => v).length + (_dailyChallengeCompleted ? 2 : 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('👥 Habit Universe'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _avatar = value;
              });
            },
            itemBuilder: (ctx) => ['🧠', '🐸', '🐱', '🧘', '🐺']
                .map((e) => PopupMenuItem(value: e, child: Text("Avatar $e")))
                .toList(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Text("$_avatar", style: TextStyle(fontSize: 40)),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: "Ce problemă ai?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _loading ? null : () => getTasksFromFlask(_controller.text),
                  child: Text("Generează"),
                ),
              ],
            ),
            if (_loading)
              Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TasksScreen(
                      initialTasks: _tasks,
                      initialChecked: _checked,
                      initialReactions: _reactions,
                      onTasksUpdated: _onTasksUpdated,
                    ),
                  ),
                ).then((_) => _loadSavedData());
              },
              child: Text("📋 Vezi activitățile"),
            ),
            Divider(),
            Text("🏅 Clasament"),
            Expanded(
              child: ListView.builder(
                itemCount: _leaderboard.length,
                itemBuilder: (context, index) {
                  final user = _leaderboard[index];
                  return ListTile(
                    leading: Text("#${index + 1}"),
                    title: Text(user['username']),
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
