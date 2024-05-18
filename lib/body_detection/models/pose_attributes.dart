import 'dart:math' as math;

import 'point3d.dart';
import 'pose_landmark_type.dart';

class PoseAttributes {
  dynamic elbowAngle;
  dynamic elbowAngleValid;

  dynamic shoulderAngle;
  dynamic shoulderAngleValid;

  dynamic kneeAngle;
  dynamic kneeAngleValid;

  dynamic legAngle;
  dynamic legAngleValid;

  dynamic hipAngle;
  dynamic hipAngleValid;

  dynamic hipDepth;

  PoseAttributes();

  factory PoseAttributes.fromMap(Map<Object?, Object?> map) {
    return PoseAttributes();
  }

  void clear() {
    elbowAngle = null;
    elbowAngleValid = null;

    shoulderAngle = null;
    shoulderAngleValid = null;

    kneeAngle = null;
    kneeAngleValid = null;

    legAngle = null;
    legAngleValid = null;

    hipAngle = null;
    hipAngleValid = null;

    hipDepth = null;
  }

  double euclideanDistance(double x1, double y1, double x2, double y2) {
    return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
  }

  double calculateLineAngle(double x1, double y1, double x2, double y2) {
    double radians = math.atan2(y2 - y1, x2 - x1);
    return double.parse((radians * (180 / math.pi)).toStringAsFixed(2));
  }

  double calculateAngle(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    double d1 = euclideanDistance(x1, y1, x2, y2);
    double d2 = euclideanDistance(x2, y2, x3, y3);
    double d3 = euclideanDistance(x3, y3, x1, y1);

    double radians = math.acos((d1 * d1 + d2 * d2 - d3 * d3) / (2 * d1 * d2));
    return double.parse((radians * (180 / math.pi)).toStringAsFixed(2));
  }

  double calculateAngleFromPoints(Point3d a, Point3d b, Point3d c) {
    return calculateAngle(a.x, a.y, b.x, b.y, c.x, c.y);
  }

  double calculateLineAngleFromPoints(Point3d a, Point3d b) {
    return calculateLineAngle(a.x, a.y, b.x, b.y);
  }

  double calculateLegAngle(Point3d knee, Point3d b, Point3d c) {
    return calculateAngle(knee.x, knee.y, (b.x + c.x) / 2, (b.y + c.y) / 2,
        (b.x + c.x) / 2, knee.y);
  }

  bool validateRange(double? value, double lower, double higher) {
    return (value != null && value >= lower && value <= higher);
  }

  bool validateHipDepth(double? depthLeft, double? depthRight) {
    return (depthLeft != null &&
        depthRight != null &&
        depthLeft < 0 &&
        depthRight >= 0);
  }

  void setHipDepth(double value) {
    hipDepth = value;
  }

  void setHipAngle(double value) {
    hipAngle = value;
  }

  void setElbowAngle(double value) {
    elbowAngle = value;
  }

  void setShoulderAngle(double value) {
    shoulderAngle = value;
  }

  void setKneeAngle(double value) {
    kneeAngle = value;
  }

  void setLegAngle(double value) {
    legAngle = value;
  }

  void setElbowAngleValid(bool value) {
    elbowAngleValid = value;
  }

  void setShoulderAngleValid(bool value) {
    shoulderAngleValid = value;
  }

  void setKneeAngleValid(bool value) {
    kneeAngleValid = value;
  }

  void setLegAngleValid(bool value) {
    legAngleValid = value;
  }

  void setHipAngleValid(bool value) {
    hipAngleValid = value;
  }

  static const List<PoseLandmarkType> validLandmarkType = [
    PoseLandmarkType.leftWrist,
    PoseLandmarkType.leftElbow,
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.leftKnee,
    PoseLandmarkType.leftAnkle,
    PoseLandmarkType.rightWrist,
    PoseLandmarkType.rightElbow,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.rightHip,
    PoseLandmarkType.rightKnee,
    PoseLandmarkType.rightAnkle,
  ];
}
