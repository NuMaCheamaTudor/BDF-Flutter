import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_screen.dart';
import 'package:http/http.dart' as http;

Future<List<String>> fetchChallengeFromClaudeAPI() async {
  final url = Uri.parse('http://192.168.0.110:5001/ask');

  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final content = data['response'] as String;

    final lines = content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return lines;
  } else {
    throw Exception('Failed to fetch challenges from Claude API: \${response.statusCode}');
  }
}

class DailyChallenge extends StatefulWidget {
  @override
  _DailyChallengeState createState() => _DailyChallengeState();
}

class _DailyChallengeState extends State<DailyChallenge>
    with SingleTickerProviderStateMixin {
  String _currentChallenge = "Loading challenge...";
  bool _isCompleted = false;
  CameraDescription? _camera;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _initCamera();
    _loadOrFetchChallenge();
  }

  Future<void> _loadOrFetchChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();

    if (prefs.containsKey(todayKey)) {
      setState(() {
        _currentChallenge =
            prefs.getString(todayKey) ?? "Niciun challenge disponibil.";
        _isCompleted = prefs.getBool(todayKey + "_completed") ?? false;
      });
      return;
    }

    try {
      final challenges = await fetchChallengeFromClaudeAPI();
      final randomChallenge = challenges.isNotEmpty
          ? (challenges..shuffle()).first
          : "Fă o plimbare de 15 minute.";

      await prefs.setString(todayKey, randomChallenge);
      await prefs.setBool(todayKey + "_completed", false);

      setState(() {
        _currentChallenge = randomChallenge;
        _isCompleted = false;
      });
    } catch (e) {
      setState(() {
        _currentChallenge = "Fă o plimbare de 15 minute.";
        _isCompleted = false;
      });
    }
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return 'challenge_\${now.year}-\${now.month}-\${now.day + 2}';
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      setState(() {
        _camera = cameras.first;
      });
    }
  }

  void _openCamera() async {
    if (_camera == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(camera: _camera!),
      ),
    );
  }

  void _completeChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();

    setState(() {
      _isCompleted = true;
    });

    await prefs.setBool(todayKey + "_completed", true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text('Daily Challenge'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.1).animate(CurvedAnimation(
                    parent: _animationController, curve: Curves.easeInOut)),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Text(
                    _currentChallenge,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: _isCompleted ? Colors.green : Colors.black87,
                      decoration: _isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                duration: Duration(milliseconds: 600),
                opacity: _isCompleted ? 0.4 : 1.0,
                child: ElevatedButton(
                  onPressed: _isCompleted ? null : _completeChallenge,
                  child: Text(
                    _isCompleted ? "Completat!" : "Completează task-ul",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: Icon(Icons.camera_alt_outlined),
                label: const Text('Fă o poză ✨'),
                onPressed: _openCamera,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.deepPurple),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}