import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'login_page.dart';
import '../register/buat_pass_screen.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../api/auth.dart';

class FaceRecogScreen extends StatefulWidget {
  final bool isFromRegister;

  const FaceRecogScreen({super.key, this.isFromRegister = false});

  @override
  State<FaceRecogScreen> createState() => _FaceRecogScreenState();
}

enum LivenessStep { lookStraight, lookLeft, lookRight, blink, done }

class _FaceRecogScreenState extends State<FaceRecogScreen> {
  late CameraController _controller;
  bool isCameraReady = false;
  bool isProcessing = false;

  LivenessStep currentStep = LivenessStep.lookStraight;

  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller.initialize();

    setState(() => isCameraReady = true);

    startImageStream();
  }

  void startImageStream() {
    _controller.startImageStream((image) async {
      if (isProcessing) return;

      isProcessing = true;

      try {
        final inputImage = _inputImageFromCameraImage(image);

        final faces = await faceDetector.processImage(inputImage);

        if (faces.isNotEmpty) {
          processFace(faces.first);
        }
      } catch (e) {
        print(e);
      }

      isProcessing = false;
    });
  }

  void processFace(Face face) {
    final headY = face.headEulerAngleY ?? 0;
    final leftEye = face.leftEyeOpenProbability ?? 1;
    final rightEye = face.rightEyeOpenProbability ?? 1;

    switch (currentStep) {
      case LivenessStep.lookStraight:
        if (headY.abs() < 10) {
          setState(() => currentStep = LivenessStep.lookLeft);
        }
        break;

      case LivenessStep.lookLeft:
        if (headY < -15) {
          setState(() => currentStep = LivenessStep.lookRight);
        }
        break;

      case LivenessStep.lookRight:
        if (headY > 15) {
          setState(() => currentStep = LivenessStep.blink);
        }
        break;

      case LivenessStep.blink:
        if (leftEye < 0.3 && rightEye < 0.3) {
          setState(() => currentStep = LivenessStep.done);
          captureImage();
        }
        break;

      case LivenessStep.done:
        break;
    }
  }

  Future<void> captureImage() async {
    final file = await _controller.takePicture();
    File imageFile = File(file.path);

    try {
      await AuthService.uploadFaceImage(imageFile);

      if (widget.isFromRegister) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BuatPassScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal upload wajah: $e")));
    }
  }

  String getInstruction() {
    switch (currentStep) {
      case LivenessStep.lookStraight:
        return "Hadapkan wajah ke depan";
      case LivenessStep.lookLeft:
        return "Hadap ke kiri";
      case LivenessStep.lookRight:
        return "Hadap ke kanan";
      case LivenessStep.blink:
        return "Kedipkan mata";
      default:
        return "Memproses...";
    }
  }

  InputImage _inputImageFromCameraImage(CameraImage image) {
    final allBytes = BytesBuilder(copy: false);

    for (Plane plane in image.planes) {
      allBytes.add(plane.bytes);
    }

    final bytes = allBytes.takeBytes();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation: InputImageRotation.rotation0deg,
      format: inputImageFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageData);
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: Colors.white,
      body: isCameraReady
          ? Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(_controller),

                Positioned(
                  top: 100,
                  child: Text(
                    getInstruction(),
                    style: alumniSansBold.copyWith(
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
