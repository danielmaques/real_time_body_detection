import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:real_time_body_detection/real_time_body_detection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BodyDetectionCamera(
        frontalValidation: true,
        onImagesCaptured:
            (List<Uint8List> capturedImages, bool frontalValidation) {},
        capturedImages: [],
      ),
    );
  }
}
