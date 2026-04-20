import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'hand_provider.dart';

class RainbowPainter extends CustomPainter {
  const RainbowPainter({
    required this.model,
    this.strokeWidth = 3.0,
    this.glowSigma = 5.0,
    this.pinchDistanceThreshold = 0.08,
  });

  final HandModel model;
  final double strokeWidth;
  final double glowSigma;
  final double pinchDistanceThreshold;

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
    final pinchStrength = _pinchStrength(left, right);
    final widthBoost = 1.0 + (pinchStrength * 1.8);
    final glowBoost = 1.0 + (pinchStrength * 2.2);

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

      final hue = ((i / count) + framePhase) % 1.0 * 360.0;
      final rainbow = HSVColor.fromAHSV(
        1.0,
        hue,
        0.85 + (0.15 * pinchStrength),
        0.90 + (0.10 * pinchStrength),
      ).toColor();

      final bloomPaint = Paint()
        ..color = rainbow.withValues(alpha: 0.20 + (0.25 * pinchStrength))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = (strokeWidth + 6.0) * widthBoost
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma * 1.8 * glowBoost);

      final glowPaint = Paint()
        ..color = rainbow.withValues(alpha: 0.40 + (0.25 * pinchStrength))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = (strokeWidth + 2.0) * widthBoost
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowSigma * glowBoost);

      final linePaint = Paint()
        ..color = rainbow
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth * widthBoost;

      canvas.drawLine(start, end, bloomPaint);
      canvas.drawLine(start, end, glowPaint);
      canvas.drawLine(start, end, linePaint);
    }
  }

  double _pinchStrength(List<HandPoint> left, List<HandPoint> right) {
    const fingerTips = <int>[4, 8, 12, 16, 20];
    double? minDistance;

    for (final tip in fingerTips) {
      if (tip >= left.length || tip >= right.length) {
        continue;
      }
      final leftTip = left[tip];
      final rightTip = right[tip];
      if (!leftTip.isValid || !rightTip.isValid) {
        continue;
      }

      final dx = leftTip.x! - rightTip.x!;
      final dy = leftTip.y! - rightTip.y!;
      final distance = math.sqrt((dx * dx) + (dy * dy));
      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
      }
    }

    if (minDistance == null) {
      return 0.0;
    }

    final normalized = ((pinchDistanceThreshold - minDistance) / pinchDistanceThreshold).clamp(0.0, 1.0);
    return normalized;
  }

  @override
  bool shouldRepaint(covariant RainbowPainter oldDelegate) {
    return oldDelegate.model != model ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.glowSigma != glowSigma ||
        oldDelegate.pinchDistanceThreshold != pinchDistanceThreshold;
  }
}
