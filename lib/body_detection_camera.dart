import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'body_detection/body_detection.dart';
import 'body_detection/camera_painter.dart';
import 'body_detection/models/body_mask.dart';
import 'body_detection/models/image_result.dart';
import 'body_detection/models/pose.dart';

typedef ImageCaptureCallback = void Function(
    List<Uint8List> capturedImages, bool frontalValidation);

class BodyDetectionCamera extends StatefulWidget {
  const BodyDetectionCamera({
    super.key,
    required this.frontalValidation,
    required this.onImagesCaptured,
    required this.capturedImages,
  });

  final bool frontalValidation;
  final ImageCaptureCallback onImagesCaptured;
  final List<Uint8List> capturedImages;

  @override
  State<BodyDetectionCamera> createState() => _BodyDetectionCameraPageState();
}

class _BodyDetectionCameraPageState extends State<BodyDetectionCamera> {
  late bool front = true;

  @override
  void initState() {
    super.initState();
    _startCameraStream();
    _toggleDetectPose();
    _toggleDetectBodyMask();
    _frontalValidation = widget.frontalValidation;
    _capturedImages = List<Uint8List>.from(widget.capturedImages);
  }

  // == Detection Properties ==
  bool _frontalValidation = true;
  bool _isDetectingPose = true;
  bool _isDetectingBodyMask = false;

  // == Camera Image Properties ==
  Image? _cameraImage;
  Size _imageSize = Size.zero;
  Uint8List? _cameraImageBytes;

  // == Detection Current State ==
  Pose? _detectedPose;
  ui.Image? _maskImage;

  // == Image Storage Controllers ==
  bool _imageCaptured = false;
  List<Uint8List> _capturedImages = [];

  Future<void> _startCameraStream() async {
    final request = await Permission.camera.request();
    if (request.isGranted) {
      await BodyDetection.startCameraStream(
        onFrameAvailable: _handleCameraImage,
        onPoseAvailable: (pose) {
          if (!_isDetectingPose) return;
          _handlePose(pose);
        },
        onMaskAvailable: (mask) {
          if (!_isDetectingBodyMask) return;
          _handleBodyMask(mask);
        },
      );
    }
  }

  // void switchToCamera(bool isFront) {
  //   BodyDetection.switchCamera(isFront: isFront);
  // }

  void _handleCameraImage(ImageResult result) {
    if (!mounted) return;

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    final image = Image.memory(
      result.bytes,
      gaplessPlayback: true,
      fit: BoxFit.contain,
    );

    setState(() {
      _cameraImageBytes = result.bytes;
      _cameraImage = image;
      _imageSize = result.size;
    });
  }

  void _handlePose(Pose? pose) {
    if (!mounted) return;

    bool isValid = false;
    if (_frontalValidation) {
      isValid = pose!.validateFrontalImage(_imageSize);
    } else {
      isValid = pose!.validateSideImage(_imageSize);
    }

    if (isValid) {
      _saveImage();
      BodyDetection.stopCameraStream();
    }

    setState(() {
      _detectedPose = pose;
    });
  }

  void _handleBodyMask(BodyMask? mask) {
    if (!mounted) return;

    if (mask == null) {
      setState(() {
        _maskImage = null;
      });
      return;
    }

    final bytes = mask.buffer
        .expand(
          (it) => [0, 0, 0, (it * 255).toInt()],
        )
        .toList();
    ui.decodeImageFromPixels(Uint8List.fromList(bytes), mask.width, mask.height,
        ui.PixelFormat.rgba8888, (image) {
      setState(() {
        _maskImage = image;
      });
    });
  }

  Future<void> _toggleDetectPose() async {
    await BodyDetection.enablePoseDetection();

    setState(() {
      _isDetectingPose = _isDetectingPose;
      _detectedPose = null;
    });
  }

  Future<void> _toggleDetectBodyMask() async {
    await BodyDetection.enableBodyMaskDetection();

    setState(() {
      _isDetectingBodyMask = _isDetectingBodyMask;
      _maskImage = null;
    });
  }

  Future<void> _saveImage() async {
    if (_imageCaptured) return;
    if (_cameraImageBytes == null) return;

    _capturedImages.add(_cameraImageBytes!);
    widget.onImagesCaptured(_capturedImages, _frontalValidation);

    setState(() {
      _imageCaptured = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        foregroundPainter: CameraPainter(
          pose: _detectedPose,
          mask: _maskImage,
          imageSize: _imageSize,
          frontalValidation: _frontalValidation,
        ),
        child: _cameraImage,
      ),
    );
  }
}
