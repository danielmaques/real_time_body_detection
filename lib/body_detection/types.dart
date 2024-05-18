import 'models/body_mask.dart';
import 'models/image_result.dart';
import 'models/pose.dart';

typedef ImageCallback = Function(ImageResult result);
typedef PoseCallback = Function(Pose? result);
typedef BodyMaskCallback = Function(BodyMask? result);
