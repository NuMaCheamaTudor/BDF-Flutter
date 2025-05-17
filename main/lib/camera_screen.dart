import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:lottie/lottie.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    _requestPermissions();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animController.forward();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile picture = await _controller.takePicture();

      final List<Directory>? extDirs =
          await getExternalStorageDirectories(type: StorageDirectory.dcim);
      final Directory dcimDir = extDirs!.first;

      final String customFolder = path.join(dcimDir.path, 'MyApp');
      final Directory targetDir = Directory(customFolder);

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(targetDir.path, fileName);

      await File(picture.path).copy(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📸 Poză salvată în DCIM/MyApp')),
      );

      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Eroare la salvare poză')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: const Text('Camera Zen 🌸'),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _animController,
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  CameraPreview(_controller),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Lottie.asset(
                        'assets/animations/breathe.json',
                        width: 100,
                        repeat: true,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        backgroundColor: Colors.deepPurple,
                        onPressed: _takePicture,
                        child: const Icon(Icons.camera_alt, size: 30),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
