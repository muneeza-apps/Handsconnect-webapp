import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('initializeHandTracking')
external JSPromise<JSAny?> _initializeHandTracking();

@JS('getHandLandmarks')
external JSAny? _getHandLandmarks();

class HandPoint {
  const HandPoint({required this.x, required this.y});

  final double? x;
  final double? y;

  bool get isValid => x != null && y != null;
}

class HandModel {
  const HandModel({
    required this.leftHand,
    required this.rightHand,
    required this.updatedAt,
  });

  final List<HandPoint> leftHand;
  final List<HandPoint> rightHand;
  final DateTime updatedAt;

  static HandModel empty() {
    final emptyHand = List<HandPoint>.generate(
      21,
      (_) => const HandPoint(x: null, y: null),
    );
    return HandModel(
      leftHand: emptyHand,
      rightHand: emptyHand,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  factory HandModel.fromJsValue(Object? jsValue) {
    final dynamic hands = jsValue;
    if (hands is! List) {
      return HandModel.empty();
    }

    final left = _parseSingleHand(hands.isNotEmpty ? hands[0] : null);
    final right = _parseSingleHand(hands.length > 1 ? hands[1] : null);

    return HandModel(
      leftHand: left,
      rightHand: right,
      updatedAt: DateTime.now(),
    );
  }

  static List<HandPoint> _parseSingleHand(dynamic handValue) {
    if (handValue is! List) {
      return List<HandPoint>.generate(
        21,
        (_) => const HandPoint(x: null, y: null),
      );
    }

    return List<HandPoint>.generate(21, (index) {
      if (index >= handValue.length) {
        return const HandPoint(x: null, y: null);
      }

      final dynamic point = handValue[index];
      if (point is! Map) {
        return const HandPoint(x: null, y: null);
      }

      final x = (point['x'] as num?)?.toDouble();
      final y = (point['y'] as num?)?.toDouble();
      return HandPoint(x: x, y: y);
    });
  }
}

class HandProvider extends ChangeNotifier {
  HandProvider({this.smoothingAlpha = 0.30});

  /// EMA alpha: lower => smoother, higher => more responsive.
  final double smoothingAlpha;
  HandModel _model = HandModel.empty();
  HandModel? _smoothedModel;
  Timer? _pollTimer;
  bool _isStarting = false;

  HandModel get model => _model;
  bool get isStreaming => _pollTimer?.isActive ?? false;

  Future<void> start() async {
    if (_isStarting || isStreaming) {
      return;
    }
    _isStarting = true;
    try {
      await _initializeHandTracking().toDart;
      _pollTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        _pullLandmarksFromJs();
      });
    } finally {
      _isStarting = false;
    }
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _smoothedModel = null;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  void _pullLandmarksFromJs() {
    final raw = _getHandLandmarks();
    final dartValue = raw?.dartify();
    final rawModel = HandModel.fromJsValue(dartValue);
    final nextModel = _applyEma(rawModel);
    _smoothedModel = nextModel;
    _model = nextModel;
    notifyListeners();
  }

  HandModel _applyEma(HandModel current) {
    final previous = _smoothedModel;
    if (previous == null) {
      return current;
    }

    return HandModel(
      leftHand: _smoothHand(previous.leftHand, current.leftHand),
      rightHand: _smoothHand(previous.rightHand, current.rightHand),
      updatedAt: current.updatedAt,
    );
  }

  List<HandPoint> _smoothHand(List<HandPoint> previous, List<HandPoint> current) {
    return List<HandPoint>.generate(21, (index) {
      final prev = index < previous.length ? previous[index] : const HandPoint(x: null, y: null);
      final curr = index < current.length ? current[index] : const HandPoint(x: null, y: null);

      if (!curr.isValid) {
        return curr;
      }

      if (!prev.isValid) {
        return curr;
      }

      return HandPoint(
        x: _ema(prev.x!, curr.x!),
        y: _ema(prev.y!, curr.y!),
      );
    });
  }

  double _ema(double previousValue, double currentValue) {
    return (smoothingAlpha * currentValue) + ((1.0 - smoothingAlpha) * previousValue);
  }
}
