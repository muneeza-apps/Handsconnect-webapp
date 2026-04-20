import 'package:flutter/foundation.dart';

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
}

class HandProvider extends ChangeNotifier {
  HandProvider({this.smoothingAlpha = 0.30});

  final double smoothingAlpha;
  HandModel _model = HandModel.empty();

  HandModel get model => _model;
  bool get isStreaming => false;

  Future<void> start() async {
    _model = HandModel.empty();
    notifyListeners();
  }

  void stop() {}
}
