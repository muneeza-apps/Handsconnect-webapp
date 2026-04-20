import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hand_provider.dart';

class RainbowPainter extends CustomPainter {
  const RainbowPainter({
    required this.model,
  });

  final HandModel model;

  @override
  void paint(Canvas canvas, Size size) {
    final left = model.leftHand;
    final right = model.rightHand;
    final count = math.min(left.length, right.length);

    if (count == 0) {
      return;
    }

    final nowMs = DateTime.now().millisecondsSinceEpoch.toDouble();
    final framePhase = (nowMs / 2400.0) % 1.0;

    final neonColors = const [
      Color(0xFF00FFFF), // Neon Cyan
      Color(0xFF39FF14), // Neon Lime
    ];

    for (var i = 0; i < count; i++) {
      final leftPoint = left[i];
      final rightPoint = right[i];
      if (!leftPoint.isValid || !rightPoint.isValid) {
        continue;
      }

      final start = Offset(
        leftPoint.x!.clamp(0.0, 1.0) * size.width,
        leftPoint.y!.clamp(0.0, 1.0) * size.height,
      );
      final end = Offset(
        rightPoint.x!.clamp(0.0, 1.0) * size.width,
        rightPoint.y!.clamp(0.0, 1.0) * size.height,
      );

      final colorPhase = ((i / count) + framePhase) % 1.0;
      final scaledPhase = colorPhase * neonColors.length;
      final colorIndex = scaledPhase.floor();
      final nextColorIndex = (colorIndex + 1) % neonColors.length;
      final t = scaledPhase - colorIndex;
      final glowColor = Color.lerp(neonColors[colorIndex], neonColors[nextColorIndex], t)!;

      final bloomPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

      final linePaint = Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0;

      final jointPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);

      canvas.drawLine(start, end, bloomPaint);
      canvas.drawLine(start, end, linePaint);
      canvas.drawCircle(start, 3.0, jointPaint);
      canvas.drawCircle(end, 3.0, jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RainbowPainter oldDelegate) {
    return oldDelegate.model != model;
  }
}
