
import 'package:flutter/material.dart';

import '../models/detection_result.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final List<int>? imageDimensions;

  BoundingBoxPainter({
    required this.detections,
    this.imageDimensions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (imageDimensions == null || imageDimensions!.length < 2) {
      return;
    }

    final scaleX = size.width / imageDimensions![0];
    final scaleY = size.height / imageDimensions![1];

    for (int i = 0; i < detections.length; i++) {
      final detection = detections[i];
      final color = _getColorForClass(detection.className);

      final x1 = detection.bbox[0] * scaleX;
      final y1 = detection.bbox[1] * scaleY;
      final x2 = detection.bbox[2] * scaleX;
      final y2 = detection.bbox[3] * scaleY;

      final rect = Rect.fromLTRB(x1, y1, x2, y2);

      // Borda preta externa
      final outerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..color = Colors.black;
      canvas.drawRect(rect, outerPaint);

      // Borda colorida interna
      final innerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = color;
      canvas.drawRect(rect, innerPaint);

      // Label
      final label = '${i + 1}. ${_translateClassName(detection.className)} ${(detection.confidence * 100).toInt()}%';

      final textSpan = TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 2,
              color: Colors.black54,
              offset: Offset(1, 1),
            ),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final labelY = y1 - textPainter.height - 4 < 0 ? y1 + 4 : y1 - textPainter.height - 4;

      final textRect = Rect.fromLTWH(
        x1,
        labelY,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      // Fundo do label
      canvas.drawRect(textRect, Paint()..color = color.withOpacity(0.7));
      // Texto
      textPainter.paint(canvas, Offset(x1 + 4, labelY + 2));
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.detections != detections ||
        oldDelegate.imageDimensions != imageDimensions;
  }

  Color _getColorForClass(String className) {
    const colors = {
      'car': Colors.blue,
      'truck': Colors.green,
      'bus': Colors.orange,
      'motorcycle': Colors.purple,
    };
    return colors[className.toLowerCase()] ?? Colors.red;
  }

  String _translateClassName(String className) {
    const translations = {
      'car': 'Carro',
      'truck': 'Caminhão',
      'bus': 'Ônibus',
      'motorcycle': 'Moto',
    };
    return translations[className.toLowerCase()] ?? className;
  }
}