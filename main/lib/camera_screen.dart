import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future<void> _takePicture() async {
  try {
    await _initializeControllerFuture;
    final XFile picture = await _controller.takePicture();

    final List<Directory>? extDirs = await getExternalStorageDirectories(type: StorageDirectory.dcim);
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
      SnackBar(content: Text('Poză salvată în DCIM/MyApp')),
    );

    Navigator.pop(context);

  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Eroare la salvare poză')),
    );
  }
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      onPressed: _takePicture,
                      child: Icon(Icons.camera_alt),
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
    );
  }
}
