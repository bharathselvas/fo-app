import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// In-app Android camera with Use Photo / Retake review.
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initFuture;
  XFile? _captured;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  Future<void> _setup() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'No camera available');
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _controller = controller;
      _initFuture = controller.initialize();
      await _initFuture;
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _error = 'Camera error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed && _captured == null) {
      _setup();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      setState(() => _captured = file);
    } catch (e) {
      setState(() => _error = 'Capture failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<List<int>?> _readCaptured() async {
    final f = _captured;
    if (f == null) return null;
    return File(f.path).readAsBytes();
  }

  Future<void> _usePhoto() async {
    final bytes = await _readCaptured();
    if (bytes == null) return;
    // Move to stable app documents path before returning
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/field_data/pending');
    await dir.create(recursive: true);
    final dest = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${p.basename(_captured!.path)}';
    await File(dest).writeAsBytes(bytes, flush: true);
    if (mounted) Navigator.of(context).pop(dest);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!))),
      );
    }

    if (_captured != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('Review Photo'), backgroundColor: Colors.black),
        body: Column(
          children: [
            Expanded(child: Image.file(File(_captured!.path), fit: BoxFit.contain)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                        onPressed: () => setState(() => _captured = null),
                        child: const Text('Retake'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(onPressed: _usePhoto, child: const Text('Use Photo')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Capture Evidence'), backgroundColor: Colors.black),
      body: Column(
        children: [
          Expanded(child: CameraPreview(controller)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.large(
                    onPressed: _busy ? null : _capture,
                    child: _busy
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.camera_alt, size: 36),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
