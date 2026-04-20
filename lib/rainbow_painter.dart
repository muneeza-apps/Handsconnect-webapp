import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hand_provider.dart';

class RainbowPainter extends CustomPainter {
  const RainbowPainter({
    required this.model,
  });

  final HandModel model;

  static const List<List<int>> _connections = [
    [0, 1], [1, 2], [2, 3], [3, 4],       // Thumb
    [0, 5], [5, 6], [6, 7], [7, 8],       // Index
    [5, 9], [9, 10], [10, 11], [11, 12],  // Middle
    [9, 13], [13, 14], [14, 15], [15, 16],// Ring
    [13, 17], [17, 18], [18, 19], [19, 20],// Pinky
    [0, 17]                               // Palm base
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final left = model.leftHand;
    final right = model.rightHand;

    final nowMs = DateTime.now().millisecondsSinceEpoch.toDouble();
    final framePhase = (nowMs / 2400.0) % 1.0;

    // 1. Draw Left Hand Geometry
    _drawHandGeometry(canvas, size, left, framePhase);
    
    // 2. Draw Right Hand Geometry
    _drawHandGeometry(canvas, size, right, framePhase);

    // 3. Draw String Lines (Cross-Hand Connections)
    final count = math.min(left.length, right.length);
    if (count > 0) {
      for (var i = 0; i < count; i++) {
        final p1 = left[i];
        final p2 = right[i];
        if (!p1.isValid || !p2.isValid) continue;

        final start = Offset(p1.x!.clamp(0.0, 1.0) * size.width, p1.y!.clamp(0.0, 1.0) * size.height);
        final end = Offset(p2.x!.clamp(0.0, 1.0) * size.width, p2.y!.clamp(0.0, 1.0) * size.height);

        final color = _getRainbowColor(i, 21, framePhase);
        _drawGlowingLine(canvas, start, end, color);
      }
    }

    // 4. Draw Joints for all points
    _drawJoints(canvas, size, left);
    _drawJoints(canvas, size, right);
  }

  void _drawHandGeometry(Canvas canvas, Size size, List<HandPoint> hand, double framePhase) {
    if (hand.isEmpty || hand.length < 21) return;
    if (!hand[0].isValid) return;

    for (var i = 0; i < _connections.length; i++) {
      final conn = _connections[i];
      final p1 = hand[conn[0]];
      final p2 = hand[conn[1]];

      if (!p1.isValid || !p2.isValid) continue;

      final start = Offset(p1.x!.clamp(0.0, 1.0) * size.width, p1.y!.clamp(0.0, 1.0) * size.height);
      final end = Offset(p2.x!.clamp(0.0, 1.0) * size.width, p2.y!.clamp(0.0, 1.0) * size.height);

      // Match the geometry color to the specific landmark point index so it blends with the strings
      final color = _getRainbowColor(conn[1], 21, framePhase);
      _drawGlowingLine(canvas, start, end, color);
    }
  }

  Color _getRainbowColor(int index, int total, double framePhase) {
    final hue = ((index / total) + framePhase) % 1.0 * 360.0;
    return HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
  }

  void _drawGlowingLine(Canvas canvas, Offset start, Offset end, Color color) {
    final bloomPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    canvas.drawLine(start, end, bloomPaint);
    canvas.drawLine(start, end, linePaint);
  }

  void _drawJoints(Canvas canvas, Size size, List<HandPoint> hand) {
    final jointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);

    for (final p in hand) {
      if (!p.isValid) continue;
      final offset = Offset(p.x!.clamp(0.0, 1.0) * size.width, p.y!.clamp(0.0, 1.0) * size.height);
      canvas.drawCircle(offset, 3.0, jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RainbowPainter oldDelegate) {
    return oldDelegate.model != model;
  }
}
