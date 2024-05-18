import 'pose_landmark_type.dart';

class Joint {
  final PoseLandmarkType a;
  final PoseLandmarkType b;
  final bool valid;

  Joint({required this.a, required this.b, required this.valid});

  factory Joint.fromMap(Map<Object?, Object?> map) {
    return Joint(
        a: map['a'] as PoseLandmarkType,
        b: map['b'] as PoseLandmarkType,
        valid: map['valid'] as bool);
  }
}
