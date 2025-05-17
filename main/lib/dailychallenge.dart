import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_screen.dart';
import 'package:http/http.dart' as http;

Future<List<String>> fetchChallengeFromOpenAI() async {
  final apiKey = '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';
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  final body = jsonEncode({
    "model": "gpt-4o-mini",
    "messages": [
      {
        "role": "user",
        "content": "Give me a list of 5 daily motivational challenges as short sentences."
      }
    ],
    "max_tokens": 150,
    "temperature": 0.7
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'];

    final lines = content.split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

    return lines;
  } else {
    throw Exception('Failed to fetch challenges from OpenAI: ${response.statusCode}');
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

    // Altfel, aducem lista de task-uri, alegem unul random și îl salvăm local
    try {
      final challenges = await fetchChallengeFromOpenAI();
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
    return 'challenge_${now.year}-${now.month}-${now.day}';
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
              style: TextStyle(
                fontSize: 24,
              ),
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
