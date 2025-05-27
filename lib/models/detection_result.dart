import 'package:equatable/equatable.dart';

class DetectionResult extends Equatable {
  final String className;
  final double confidence;
  final List<double> bbox;

  const DetectionResult({
    required this.className,
    required this.confidence,
    required this.bbox,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      className: json['class_name'],
      confidence: json['confidence'].toDouble(),
      bbox: List<double>.from(json['bbox'].map((x) => x.toDouble())),
    );
  }

  @override
  List<Object> get props => [className, confidence, bbox];
}

class ApiResponse extends Equatable {
  final bool success;
  final String message;
  final List<DetectionResult>? detections;
  final double? processingTime;
  final List<int>? imageDimensions;

  const ApiResponse({
    required this.success,
    required this.message,
    this.detections,
    this.processingTime,
    this.imageDimensions,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'],
      message: json['message'],
      detections: json['detections'] != null
          ? List<DetectionResult>.from(
          json['detections'].map((x) => DetectionResult.fromJson(x)))
          : null,
      processingTime: json['processing_time']?.toDouble(),
      imageDimensions: json['image_dimensions'] != null
          ? List<int>.from(json['image_dimensions'])
          : null,
    );
  }

  @override
  List<Object?> get props => [success, message, detections, processingTime, imageDimensions];
}