import 'dart:async';

import 'package:flutter/material.dart';

import 'hand_provider.dart';
import 'rainbow_painter.dart';
import 'web_camera_view.dart';

const String _cameraViewType = 'hand-camera-view';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HandTrackingApp());
}

class HandTrackingApp extends StatelessWidget {
  const HandTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HandTrackingScreen(),
    );
  }
}

class HandTrackingScreen extends StatefulWidget {
  const HandTrackingScreen({super.key});

  @override
  State<HandTrackingScreen> createState() => _HandTrackingScreenState();
}

class _HandTrackingScreenState extends State<HandTrackingScreen> {
  late final HandProvider _provider;
  Timer? _videoAttachTimer;
  int _cameraRevision = 0;

  @override
  void initState() {
    super.initState();
    _provider = HandProvider();
    registerCameraViewFactory(_cameraViewType);
    _provider.start();
    _videoAttachTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      _attachVideoIfAvailable();
    });
  }

  void _attachVideoIfAvailable() {
    if (attachVideoIfAvailable()) {
      _videoAttachTimer?.cancel();
      _videoAttachTimer = null;
      setState(() {
        _cameraRevision += 1;
      });
    }
  }

  @override
  void dispose() {
    _videoAttachTimer?.cancel();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          buildCameraView(
            key: ValueKey(_cameraRevision),
            viewType: _cameraViewType,
          ),
          AnimatedBuilder(
            animation: _provider,
            builder: (context, _) {
              return CustomPaint(
                painter: RainbowPainter(model: _provider.model),
                size: Size.infinite,
              );
            },
          ),
        ],
      ),
    );
  }
}
