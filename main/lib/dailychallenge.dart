import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';

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

  late String _randomChallenge;
  CameraDescription? _camera;

  @override
  void initState() {
    super.initState();
    _generateRandomChallenge();
    _initCamera();
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
