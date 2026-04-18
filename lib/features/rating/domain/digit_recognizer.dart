import 'dart:math' as math;

class DigitRecognition {
  const DigitRecognition({
    required this.digit,
    required this.confidence,
    required this.scores,
  });

  final int digit;
  final double confidence;
  final List<double> scores;
}

class DigitRecognizer {
  static const int size = 5;

  // 5x5 templates for digits 0..9.
  static const List<List<int>> _templates = <List<int>>[
    [1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1],
    [0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0],
    [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0],
    [1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],
  ];

  DigitRecognition recognize(List<bool> input) {
    if (input.length != size * size) {
      throw ArgumentError('Input length must be ${size * size}');
    }

    final inputVec = input.map((v) => v ? 1 : 0).toList(growable: false);
    final scores = List<double>.filled(_templates.length, 0);

    for (var d = 0; d < _templates.length; d++) {
      var dot = 0;
      var mismatch = 0;
      for (var i = 0; i < inputVec.length; i++) {
        dot += inputVec[i] * _templates[d][i];
        if (inputVec[i] != _templates[d][i]) mismatch++;
      }
      scores[d] = dot - mismatch * 0.25;
    }

    var bestIdx = 0;
    var bestScore = scores[0];
    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIdx = i;
      }
    }

    final probs = _softmax(scores);
    return DigitRecognition(digit: bestIdx, confidence: probs[bestIdx], scores: probs);
  }

  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce((a, b) => a > b ? a : b);
    final exps = logits.map((x) => math.exp(x - maxLogit)).toList(growable: false);
    final sum = exps.fold<double>(0, (acc, e) => acc + e);
    return exps.map((e) => e / sum).toList(growable: false);
  }
}
