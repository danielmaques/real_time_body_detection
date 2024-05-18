import 'dart:ui';

import 'pose_attributes.dart';
import 'pose_joint.dart';
import 'pose_landmark.dart';
import 'pose_landmark_type.dart';

class Pose {
  final List<PoseLandmark> landmarks;
  PoseAttributes poseLeftAtt = PoseAttributes();
  PoseAttributes poseRightAtt = PoseAttributes();
  List<PoseLandmarkType> invalidLandmarks = [];

  Pose({required this.landmarks});

  factory Pose.fromMap(Map<Object?, Object?> map) {
    final landmarkObjectList = map['landmarks'] as List;
    final landmarkList =
        landmarkObjectList.map((it) => PoseLandmark.fromMap(it)).toList();
    return Pose(landmarks: landmarkList);
  }

  List<PoseLandmarkType> getInvalidLandmarks(
      Map<PoseLandmarkType, PoseLandmark> landmarksByType, Size imageSize) {
    if (imageSize == Size.zero) {
      return [];
    } else {
      return PoseAttributes.validLandmarkType
          .where((it) =>
              landmarksByType[it]?.inFrameLikelihood == null ||
              landmarksByType[it]!.position.x >= imageSize.width ||
              landmarksByType[it]!.position.x <= 0 ||
              landmarksByType[it]!.position.y >= imageSize.height ||
              landmarksByType[it]!.position.y <= 0)
          .toList();
    }
  }

  bool validateSideImage(Size imageSize) {
    final landmarksByType = {for (final it in landmarks) it.type: it};
    invalidLandmarks = getInvalidLandmarks(landmarksByType, imageSize);

    poseLeftAtt.clear();
    poseRightAtt.clear();

    calculateSideAttributes(landmarksByType);
    validateSideAttributes();

    return isValid();
  }

  void calculateSideAttributes(
      Map<PoseLandmarkType, PoseLandmark> landmarksByType) {
    // Left Angles
    poseLeftAtt.setElbowAngle(poseLeftAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.leftWrist]!.position,
      landmarksByType[PoseLandmarkType.leftElbow]!.position,
      landmarksByType[PoseLandmarkType.leftShoulder]!.position,
    ));
    poseLeftAtt.setShoulderAngle(poseLeftAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.leftElbow]!.position,
      landmarksByType[PoseLandmarkType.leftShoulder]!.position,
      landmarksByType[PoseLandmarkType.leftHip]!.position,
    ));
    poseLeftAtt.setKneeAngle(poseLeftAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.leftAnkle]!.position,
      landmarksByType[PoseLandmarkType.leftKnee]!.position,
      landmarksByType[PoseLandmarkType.leftHip]!.position,
    ));
    poseLeftAtt
        .setHipDepth(landmarksByType[PoseLandmarkType.leftHip]!.position.z);
    poseLeftAtt.setHipAngle(poseLeftAtt.calculateLineAngleFromPoints(
      landmarksByType[PoseLandmarkType.leftShoulder]!.position,
      landmarksByType[PoseLandmarkType.leftHip]!.position,
    ));

    // Right Angles
    poseRightAtt.setElbowAngle(poseRightAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.rightWrist]!.position,
      landmarksByType[PoseLandmarkType.rightElbow]!.position,
      landmarksByType[PoseLandmarkType.rightShoulder]!.position,
    ));
    poseRightAtt.setShoulderAngle(poseRightAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.rightElbow]!.position,
      landmarksByType[PoseLandmarkType.rightShoulder]!.position,
      landmarksByType[PoseLandmarkType.rightHip]!.position,
    ));
    poseRightAtt.setKneeAngle(poseRightAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.rightAnkle]!.position,
      landmarksByType[PoseLandmarkType.rightKnee]!.position,
      landmarksByType[PoseLandmarkType.rightHip]!.position,
    ));
    poseRightAtt.setHipAngle(poseRightAtt.calculateLineAngleFromPoints(
      landmarksByType[PoseLandmarkType.rightShoulder]!.position,
      landmarksByType[PoseLandmarkType.rightHip]!.position,
    ));
    poseRightAtt
        .setHipDepth(landmarksByType[PoseLandmarkType.rightHip]!.position.z);
  }

  void validateSideAttributes({
    double minElbowAngle = 160,
    double maxElbowAngle = 190,
    double minKneeAngle = 160,
    double maxKneeAngle = 190,
    double minShoulderAngle = 70,
    double maxShoulderAngle = 95,
    double minHipAngle = 75,
    double maxHipAngle = 95,
  }) {
    // Left Attributes
    poseLeftAtt.setElbowAngleValid(poseLeftAtt.validateRange(
        poseLeftAtt.elbowAngle, minElbowAngle, maxElbowAngle));
    poseLeftAtt.setShoulderAngleValid(poseLeftAtt.validateRange(
            poseLeftAtt.shoulderAngle, minShoulderAngle, maxShoulderAngle) &&
        poseLeftAtt.validateHipDepth(
            poseLeftAtt.hipDepth, poseRightAtt.hipDepth));
    poseLeftAtt.setKneeAngleValid(poseLeftAtt.validateRange(
        poseLeftAtt.kneeAngle, minKneeAngle, maxKneeAngle));
    poseLeftAtt.setLegAngleValid(true);
    poseLeftAtt.setHipAngleValid(poseLeftAtt.validateRange(
        poseLeftAtt.hipAngle, minHipAngle, maxHipAngle));

    // Right Attributes
    poseRightAtt.setElbowAngleValid(poseRightAtt.validateRange(
        poseRightAtt.elbowAngle, minElbowAngle, maxElbowAngle));
    poseRightAtt.setShoulderAngleValid(poseRightAtt.validateRange(
            poseRightAtt.shoulderAngle, minShoulderAngle, maxShoulderAngle) &&
        poseLeftAtt.validateHipDepth(
            poseLeftAtt.hipDepth, poseRightAtt.hipDepth));
    poseRightAtt.setKneeAngleValid(poseRightAtt.validateRange(
        poseRightAtt.kneeAngle, minKneeAngle, maxKneeAngle));
    poseRightAtt.setLegAngleValid(true);
    poseRightAtt.setHipAngleValid(poseRightAtt.validateRange(
        poseRightAtt.hipAngle, minHipAngle, maxHipAngle));
  }

  bool validateFrontalImage(Size imageSize) {
    final landmarksByType = {for (final it in landmarks) it.type: it};
    invalidLandmarks = getInvalidLandmarks(landmarksByType, imageSize);

    poseLeftAtt.clear();
    poseRightAtt.clear();

    calculateFontalAttributes(landmarksByType);
    validateFontalAttributes();

    return isValid();
  }

  void calculateFontalAttributes(
      Map<PoseLandmarkType, PoseLandmark> landmarksByType) {
    // Left Attributes
    poseLeftAtt.setElbowAngle(poseLeftAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.leftWrist]!.position,
      landmarksByType[PoseLandmarkType.leftElbow]!.position,
      landmarksByType[PoseLandmarkType.leftShoulder]!.position,
    ));
    poseLeftAtt.setShoulderAngle(poseLeftAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.leftElbow]!.position,
      landmarksByType[PoseLandmarkType.leftShoulder]!.position,
      landmarksByType[PoseLandmarkType.leftHip]!.position,
    ));
    poseLeftAtt.setKneeAngle(poseLeftAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.leftAnkle]!.position,
      landmarksByType[PoseLandmarkType.leftKnee]!.position,
      landmarksByType[PoseLandmarkType.leftHip]!.position,
    ));
    poseLeftAtt.setLegAngle(poseLeftAtt.calculateLegAngle(
      landmarksByType[PoseLandmarkType.leftKnee]!.position,
      landmarksByType[PoseLandmarkType.leftHip]!.position,
      landmarksByType[PoseLandmarkType.rightHip]!.position,
    ));

    // Right Attributes
    poseRightAtt.setElbowAngle(poseRightAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.rightWrist]!.position,
      landmarksByType[PoseLandmarkType.rightElbow]!.position,
      landmarksByType[PoseLandmarkType.rightShoulder]!.position,
    ));
    poseRightAtt.setShoulderAngle(poseRightAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.rightElbow]!.position,
      landmarksByType[PoseLandmarkType.rightShoulder]!.position,
      landmarksByType[PoseLandmarkType.rightHip]!.position,
    ));
    poseRightAtt.setKneeAngle(poseRightAtt.calculateAngleFromPoints(
      landmarksByType[PoseLandmarkType.rightAnkle]!.position,
      landmarksByType[PoseLandmarkType.rightKnee]!.position,
      landmarksByType[PoseLandmarkType.rightHip]!.position,
    ));
    poseRightAtt.setLegAngle(poseRightAtt.calculateLegAngle(
      landmarksByType[PoseLandmarkType.rightKnee]!.position,
      landmarksByType[PoseLandmarkType.rightHip]!.position,
      landmarksByType[PoseLandmarkType.leftHip]!.position,
    ));
  }

  void validateFontalAttributes({
    double minElbowAngle = 160,
    double maxElbowAngle = 190,
    double minKneeAngle = 150,
    double maxKneeAngle = 190,
    double minShoulderAngle = 50,
    double maxShoulderAngle = 70,
    double minLegAngle = 20,
    double maxLegAngle = 30,
  }) {
    // Left Attributes
    poseLeftAtt.setElbowAngleValid(poseLeftAtt.validateRange(
        poseLeftAtt.elbowAngle, minElbowAngle, maxElbowAngle));
    poseLeftAtt.setShoulderAngleValid(poseLeftAtt.validateRange(
        poseLeftAtt.shoulderAngle, minShoulderAngle, maxShoulderAngle));
    poseLeftAtt.setKneeAngleValid(poseLeftAtt.validateRange(
        poseLeftAtt.kneeAngle, minKneeAngle, maxKneeAngle));
    poseLeftAtt.setLegAngleValid(poseLeftAtt.validateRange(
        poseLeftAtt.legAngle, minLegAngle, maxLegAngle));
    poseLeftAtt.setHipAngleValid(true);

    // Right Attributes
    poseRightAtt.setElbowAngleValid(poseRightAtt.validateRange(
        poseRightAtt.elbowAngle, minElbowAngle, maxElbowAngle));
    poseRightAtt.setShoulderAngleValid(poseRightAtt.validateRange(
        poseRightAtt.shoulderAngle, minShoulderAngle, maxShoulderAngle));
    poseRightAtt.setKneeAngleValid(poseRightAtt.validateRange(
        poseRightAtt.kneeAngle, minKneeAngle, maxKneeAngle));
    poseRightAtt.setLegAngleValid(poseRightAtt.validateRange(
        poseRightAtt.legAngle, minLegAngle, maxLegAngle));
    poseRightAtt.setHipAngleValid(true);
  }

  List<Joint> getConnectionsColor() {
    return [
      Joint(
          a: PoseLandmarkType.rightShoulder,
          b: PoseLandmarkType.leftShoulder,
          valid: true),
      Joint(
          a: PoseLandmarkType.leftShoulder,
          b: PoseLandmarkType.leftHip,
          valid: poseLeftAtt.shoulderAngleValid && poseLeftAtt.hipAngleValid),
      Joint(
          a: PoseLandmarkType.rightHip,
          b: PoseLandmarkType.rightShoulder,
          valid: poseRightAtt.shoulderAngleValid),
      Joint(
          a: PoseLandmarkType.rightElbow,
          b: PoseLandmarkType.rightShoulder,
          valid: poseRightAtt.elbowAngleValid && poseRightAtt.hipAngleValid),
      Joint(
          a: PoseLandmarkType.rightWrist,
          b: PoseLandmarkType.rightElbow,
          valid: poseRightAtt.elbowAngleValid),
      Joint(
          a: PoseLandmarkType.leftHip,
          b: PoseLandmarkType.rightHip,
          valid: true),
      Joint(
          a: PoseLandmarkType.leftHip,
          b: PoseLandmarkType.leftKnee,
          valid: poseLeftAtt.kneeAngleValid && poseLeftAtt.legAngleValid),
      Joint(
          a: PoseLandmarkType.rightHip,
          b: PoseLandmarkType.rightKnee,
          valid: poseRightAtt.kneeAngleValid && poseRightAtt.legAngleValid),
      Joint(
          a: PoseLandmarkType.rightKnee,
          b: PoseLandmarkType.rightAnkle,
          valid: poseRightAtt.kneeAngleValid),
      Joint(
          a: PoseLandmarkType.leftKnee,
          b: PoseLandmarkType.leftAnkle,
          valid: poseLeftAtt.kneeAngleValid),
      Joint(
          a: PoseLandmarkType.leftShoulder,
          b: PoseLandmarkType.leftElbow,
          valid: poseLeftAtt.elbowAngleValid),
      Joint(
          a: PoseLandmarkType.leftWrist,
          b: PoseLandmarkType.leftElbow,
          valid: poseLeftAtt.elbowAngleValid),
    ];
  }

  bool isValid() {
    return (poseRightAtt.elbowAngleValid &&
        poseRightAtt.shoulderAngleValid &&
        poseRightAtt.kneeAngleValid &&
        poseRightAtt.legAngleValid &&
        poseRightAtt.hipAngleValid &&
        poseLeftAtt.elbowAngleValid &&
        poseLeftAtt.shoulderAngleValid &&
        poseLeftAtt.kneeAngleValid &&
        poseLeftAtt.legAngleValid &&
        poseLeftAtt.hipAngleValid &&
        invalidLandmarks.isEmpty);
  }

  bool shouldGoToRight() {
    return invalidLandmarks.contains(PoseLandmarkType.leftWrist) ||
        invalidLandmarks.contains(PoseLandmarkType.leftElbow) ||
        invalidLandmarks.contains(PoseLandmarkType.leftShoulder);
  }

  bool shouldGoToLeft() {
    return invalidLandmarks.contains(PoseLandmarkType.rightWrist) ||
        invalidLandmarks.contains(PoseLandmarkType.rightElbow) ||
        invalidLandmarks.contains(PoseLandmarkType.rightShoulder);
  }

  static const List<List<PoseLandmarkType>> connections = [
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.leftShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.rightWrist, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftWrist, PoseLandmarkType.leftElbow],
  ];
}
