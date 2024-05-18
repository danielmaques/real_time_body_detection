import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'models/pose.dart';
import 'models/pose_landmark.dart';

class CameraPainter extends CustomPainter {
  CameraPainter({
    required this.pose,
    required this.mask,
    required this.imageSize,
    required this.frontalValidation,
  });

  final Pose? pose;
  final ui.Image? mask;
  final Size imageSize;
  final bool frontalValidation;
  final pointPaint = Paint()..color = const ui.Color.fromARGB(0, 255, 255, 255);
  final leftPointPaint = Paint()
    ..color = const ui.Color.fromARGB(255, 55, 205, 50);
  final rightPointPaint = Paint()
    ..color = const ui.Color.fromARGB(255, 55, 205, 50);
  final linePaint = Paint()
    ..color = const ui.Color.fromARGB(255, 55, 205, 50)
    ..strokeWidth = 3;
  final lineErrorPaint = Paint()
    ..color = const ui.Color.fromARGB(255, 255, 0, 0)
    ..strokeWidth = 3;
  final maskPaint = Paint()
    ..colorFilter = const ColorFilter.mode(Colors.white30, BlendMode.srcOut);

  final isValidStyle = Paint()
    ..color = const ui.Color.fromARGB(255, 0, 255, 0)
    ..strokeWidth = 3;

  final notValidStyle = Paint()
    ..color = const ui.Color.fromARGB(255, 255, 0, 0)
    ..strokeWidth = 3;

  double animationValue = 0.0;
  String animationType = "";

  @override
  void paint(Canvas canvas, Size size) {
    // _paintMask(canvas, size);
    _paintPose(canvas, size);
  }

  void _paintPose(Canvas canvas, Size size) {
    if (pose == null) return;

    final double hRatio =
        imageSize.width == 0 ? 1 : size.width / imageSize.width;
    final double vRatio =
        imageSize.height == 0 ? 1 : size.height / imageSize.height;

    Offset offsetForPart(PoseLandmark part) =>
        Offset(part.position.x * hRatio, part.position.y * vRatio);

    // Draw landmark connections
    final landmarksByType = {for (final it in pose!.landmarks) it.type: it};
    for (final connection in pose!.getConnectionsColor()) {
      final point1 = offsetForPart(landmarksByType[connection.a]!);
      final point2 = offsetForPart(landmarksByType[connection.b]!);
      if (connection.valid) {
        canvas.drawLine(point1, point2, linePaint);
      } else {
        canvas.drawLine(point1, point2, lineErrorPaint);
      }
    }

    if (frontalValidation) {
      canvas.drawCircle(const Offset(30, 30), 10.0,
          pose!.isValid() ? isValidStyle : notValidStyle);
    } else {
      canvas.drawCircle(const Offset(30, 30), 10.0,
          pose!.isValid() ? isValidStyle : notValidStyle);
      canvas.drawCircle(const Offset(60, 30), 10.0,
          pose!.isValid() ? isValidStyle : notValidStyle);
    }

    if (animationType == "right" && animationValue < 1 ||
        animationType == "left" && animationValue < 1) {
      _runAnimation(canvas, size);
    } else if (animationType == "") {
      if (pose!.shouldGoToLeft()) {
        animationType = "left";
        _runAnimation(canvas, size);
      } else if (pose!.shouldGoToRight()) {
        animationType = "right";
        _runAnimation(canvas, size);
      }
    }
  }

  void _runAnimation(Canvas canvas, Size size) {
    animationValue = animationValue + 0.1; // Animation step

    if (animationType == "left") {
      // Draw arrow to left
    } else if (animationType == "right") {
      // Draw arrow to right
    }

    if (animationValue >= 1) {
      animationValue = 0;
      animationType = "";
    }
  }

  @override
  bool shouldRepaint(CameraPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.mask != mask ||
        oldDelegate.imageSize != imageSize;
  }
}
