class SinglePrediction {
  final String className;
  final double confidence;

  SinglePrediction({
    required this.className,
    required this.confidence,
  });

  factory SinglePrediction.fromJson(Map<String, dynamic> json) {
    return SinglePrediction(
      className: json['class_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  double get confidencePercent => confidence * 100;
}

class PredictionResult {
  final String className;
  final double confidence;
  final List<SinglePrediction> allPredictions;

  PredictionResult({
    required this.className,
    required this.confidence,
    required this.allPredictions,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      className: json['class_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      allPredictions: (json['all_predictions'] as List<dynamic>)
          .map((e) => SinglePrediction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  double get confidencePercent => confidence * 100;
  
  bool get isHighConfidence => confidence >= 0.7;
  bool get isMediumConfidence => confidence >= 0.4 && confidence < 0.7;
  bool get isLowConfidence => confidence < 0.4;
}
