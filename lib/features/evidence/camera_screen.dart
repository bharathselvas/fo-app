import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/tokens.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Sentinel result meaning "the officer chose a placeholder entry instead of
/// a real photograph" — see `CameraCaptureScreen`.
const kUsePlaceholder = '<placeholder-evidence>';

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
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Insets.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.dangerSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.no_photography_outlined,
                      size: 34,
                      color: AppColors.danger,
                    ),
                  ),
                  const Gap(Insets.xl),
                  Text(
                    'Camera Unavailable',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Gap(Insets.sm),
                  Text(
                    'This device has no usable camera. Evidence entries are still '
                    'required before a field verification can be submitted.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Gap(Insets.md),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: AppColors.textTertiary),
                  ),
                  const Gap(Insets.xl),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(kUsePlaceholder),
                    child: const Text('ADD PLACEHOLDER EVIDENCE INSTEAD'),
                  ),
                  const Gap(Insets.sm),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('BACK TO EVIDENCE'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_captured != null) {
      return Scaffold(
        backgroundColor: AppColors.viewerBackground,
        appBar: AppBar(
          title: const Text('Review Photo'),
          backgroundColor: AppColors.viewerBackground,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.file(
                  File(_captured!.path),
                  fit: BoxFit.contain,
                  // The camera captures at `ResolutionPreset.high`; decoding
                  // every pixel for a review view is wasted memory.
                  cacheWidth: MediaQuery.sizeOf(context).width.round() * 2,
                  gaplessPlayback: true,
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.viewerFooter,
                border: Border(top: BorderSide(color: AppColors.viewerDivider)),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(Insets.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.viewerOutline),
                          ),
                          onPressed: () => setState(() => _captured = null),
                          child: const Text('Retake'),
                        ),
                      ),
                      const Gap(Insets.md, horizontal: true),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.brandBright),
                          onPressed: _usePhoto,
                          child: const Text('Use Photo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      // Previously a bare spinner with no explanation. If setup produced
      // neither a controller nor an error, the officer was stuck here.
      return Scaffold(
        backgroundColor: AppColors.viewerBackground,
        appBar: AppBar(
          backgroundColor: AppColors.viewerBackground,
          foregroundColor: Colors.white,
          title: const Text('Capture Evidence'),
        ),
        body: const LoadingState(label: 'Starting the camera…'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.viewerBackground,
      appBar: AppBar(
        title: const Text('Capture Evidence'),
        backgroundColor: AppColors.viewerBackground,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(child: CameraPreview(controller)),
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.viewerFooter,
              border: Border(top: BorderSide(color: AppColors.viewerDivider)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Insets.xl),
                child: Column(
                  children: [
                    PressScale(
                      onTap: _busy ? null : _capture,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: _busy
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                      ),
                    ),
                    const Gap(Insets.md),
                    Text(
                      _busy ? 'CAPTURING…' : 'TAP TO CAPTURE',
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
