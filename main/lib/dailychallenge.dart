import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'package:http/http.dart' as http;

Future<List<String>> fetchChallengesFromOpenAI() async {
  final apiKey = '';  // pune aici cheia ta reală
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
  List<String> _challenges = [
    'Zâmbește unui străin.',
    'Scrie 3 lucruri pentru care ești recunoscător.',
    'Fă o plimbare de 15 minute.',
    'Spune cuiva un compliment sincer.',
    'Bea un pahar mare de apă.',
    'Notează un gând pozitiv în jurnal.',
  ];

  late String _randomChallenge = "Loading challenge...";
  CameraDescription? _camera;

 @override
    void initState() {
    super.initState();
    _initCamera();

    Future.delayed(Duration(seconds: 2), () {
        fetchChallengesFromOpenAI().then((fetchedChallenges) {
        setState(() {
            _challenges = fetchedChallenges;
            _generateRandomChallenge();
        });
        }).catchError((error) {
        print("Eroare la fetch: $error");
        _generateRandomChallenge();
        });
    });
    }

  void _generateRandomChallenge() {
    final random = Random();
    _randomChallenge = _challenges[random.nextInt(_challenges.length)];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenge')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              _randomChallenge,
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            Text(
              "Take a picture to feel prod!",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
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
