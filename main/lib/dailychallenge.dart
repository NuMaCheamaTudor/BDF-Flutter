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
  print("A trimis Request!");
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final content = data['response'] as String;

    final lines = content.split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return lines;
  } else {
    throw Exception('Failed to fetch challenges from Claude API: ${response.statusCode}');
  }
}

class DailyChallenge extends StatefulWidget {
  @override
  _DailyChallengeState createState() => _DailyChallengeState();
}

class _DailyChallengeState extends State<DailyChallenge> {
  String _currentChallenge = "Loading challenge...";
  bool _isCompleted = false;
  CameraDescription? _camera;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadOrFetchChallenge();
  }

  Future<void> _loadOrFetchChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();

    if (prefs.containsKey(todayKey)) {
      setState(() {
        _currentChallenge = prefs.getString(todayKey) ?? "Niciun challenge disponibil.";
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
      print("Eroare la fetch: $e");
      setState(() {
        _currentChallenge = "Fă o plimbare de 15 minute.";
        _isCompleted = false;
      });
    }
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return 'challenge_${now.year}-${now.month}-${now.day+1}';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenge')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              _currentChallenge,
              style: TextStyle(
                fontSize: 24,
                decoration: _isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                color: _isCompleted ? Colors.green : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              "Take a picture and feel proud!",
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isCompleted ? null : _completeChallenge,
              child: Text(_isCompleted ? "Completat!" : "Completează task-ul"),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _openCamera,
              icon: Icon(Icons.camera_alt),
              label: const Text('Start Camera'),
            ),
          ],
        ),
      ),
    );
  }
}
