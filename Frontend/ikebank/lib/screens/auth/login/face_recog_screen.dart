import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:ikebank/api/auth.dart';
import '../../../core/colors.dart';
import '../../../models/register_flow_data.dart';
import 'login_page.dart';
import '../register/buat_pass_screen.dart';

enum LivenessStep { lookLeft, lookRight, smile, blink, done }

class FaceRecogScreen extends StatefulWidget {
  final bool isFromRegister;
  final bool isFromCS;
  final bool isFromLupaPassword;
  final String? email;
  final String? reference;
  final RegisterFlowData? flowData;

  const FaceRecogScreen({
    super.key,
    this.isFromRegister = false,
    this.isFromLupaPassword = false,
    this.email,
    this.reference,
    this.flowData,
    this.isFromCS = false, 
  });

  @override
  State<FaceRecogScreen> createState() => _FaceRecogScreenState();
}

class _FaceRecogScreenState extends State<FaceRecogScreen> {
  static const bool _skipFaceVerify = bool.fromEnvironment(
    'SKIP_FACE_VERIFY',
    defaultValue: false,
  );

  CameraController? _controller;
  late FaceDetector _faceDetector;
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _faceDetected = false;
  String? _errorMessage;
  LivenessStep _currentStep = LivenessStep.lookLeft;
  DateTime? _lastStepChangedAt;
  bool _hasNavigated = false;
  bool _isUploadingFace = false;

  static const double _yawThreshold = 12.0;

  bool get _isDevFaceBypassEnabled =>
      _skipFaceVerify && kDebugMode; // ini diganti supaya bukan cuma os yang bisa bypass

  @override
  void initState() {
    super.initState();

    if (_isDevFaceBypassEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToNextPage(skipFaceValidation: true);
      });
      return;
    }

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
      ),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        setState(() => _errorMessage = 'Kamera tidak tersedia');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      _controller = controller;
      setState(() => _isCameraReady = true);
      _startFaceDetectionStream();
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Gagal membuka kamera: $e');
    }
  }

  void _startFaceDetectionStream() {
    final controller = _controller;
    if (controller == null) return;

    controller.startImageStream((image) async {
      if (_isProcessing) return;
      _isProcessing = true;

      try {
        final inputImage = _inputImageFromCameraImage(image);
        final faces = await _faceDetector.processImage(inputImage);
        final detected = faces.isNotEmpty;

        if (mounted && detected != _faceDetected) {
          setState(() => _faceDetected = detected);
        }

        if (faces.isNotEmpty) {
          _processLiveness(faces.first);
        }
      } catch (_) {
        // Keep UI responsive even if a frame fails to process.
      }

      _isProcessing = false;
    });
  }

  void _processLiveness(Face face) {
    if (_currentStep == LivenessStep.done) {
      return;
    }

    final headY = face.headEulerAngleY ?? 0;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 1;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1;
    final smileProbability = face.smilingProbability ?? 0;

    bool passed = false;
    switch (_currentStep) {
      case LivenessStep.lookLeft:
        // Strict left check: negative yaw only.
        passed = headY < -_yawThreshold;
        break;
      case LivenessStep.lookRight:
        // Strict right check: positive yaw only.
        passed = headY > _yawThreshold;
        break;
      case LivenessStep.smile:
        // ML Kit does not expose mouth-open probability directly, so we use
        // smile probability as a practical proxy for this step.
        passed = smileProbability > 0.55;
        break;
      case LivenessStep.blink:
        passed = leftEyeOpen < 0.4 && rightEyeOpen < 0.4;
        break;
      case LivenessStep.done:
        passed = false;
        break;
    }

    if (!passed) return;

    final now = DateTime.now();
    if (_lastStepChangedAt != null &&
        now.difference(_lastStepChangedAt!).inMilliseconds < 900) {
      return;
    }
    _lastStepChangedAt = now;

    if (!mounted) return;
    setState(() {
      switch (_currentStep) {
        case LivenessStep.lookLeft:
          _currentStep = LivenessStep.lookRight;
          break;
        case LivenessStep.lookRight:
          _currentStep = LivenessStep.smile;
          break;
        case LivenessStep.smile:
          _currentStep = LivenessStep.blink;
          break;
        case LivenessStep.blink:
          _currentStep = LivenessStep.done;
          break;
        case LivenessStep.done:
          break;
      }
    });

    if (_currentStep == LivenessStep.done) {
      _navigateToNextPage();
    }
  }

  String _instructionText() {
    switch (_currentStep) {
      case LivenessStep.lookLeft:
        return 'Hadap Kiri';
      case LivenessStep.lookRight:
        return 'Hadap Kanan';
      case LivenessStep.smile:
        return 'Senyum';
      case LivenessStep.blink:
        return 'Kedipkan Mata';
      case LivenessStep.done:
        return 'Verifikasi Selesai';
    }
  }

  InputImage _inputImageFromCameraImage(CameraImage image) {
    final allBytes = BytesBuilder(copy: false);
    for (final plane in image.planes) {
      allBytes.add(plane.bytes);
    }

    final bytes = allBytes.takeBytes();
    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation0deg,
      format: inputImageFormat,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Future<void> _onCaptureTap() async {
    if (!_faceDetected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Wajah belum terdeteksi, coba posisikan wajah di tengah.',
          ),
        ),
      );
      return;
    }

    if (_currentStep != LivenessStep.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ikuti instruksi dulu: ${_instructionText()}')),
      );
      return;
    }

    await _navigateToNextPage();
  }

  Future<void> _routeAfterFaceVerified() async {
    if (!mounted) return;

    if (widget.isFromCS) {
      Navigator.pop(context, true);
      return;
    }

    if (widget.isFromRegister) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuatPassScreen(flowData: widget.flowData),
        ),
      );
      return;
    }

    final prefilledEmail = widget.email?.trim();
    if (widget.isFromLupaPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            prefilledEmail: prefilledEmail,
            reference: widget.reference,
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          prefilledEmail: prefilledEmail,
          reference: widget.reference,
        ),
      ),
    );
  }

  Future<void> _navigateToNextPage({bool skipFaceValidation = false}) async {
    if (!mounted || _hasNavigated || _isUploadingFace) return;
    _hasNavigated = true;

    if (skipFaceValidation || _isDevFaceBypassEnabled) {
      await _routeAfterFaceVerified();
      return;
    }

    final controller = _controller;
    if (controller != null && controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }

    if (!mounted) return;

    if (widget.isFromCS || widget.isFromLupaPassword) {
      // Belum ada endpoint khusus CS/lupa password untuk validasi face di backend.
      // Untuk sementara lanjutkan alur UI agar bisa dites end-to-end.
      await _routeAfterFaceVerified();
      return;
    }

    if (widget.isFromRegister) {
      final reference = widget.reference?.trim() ?? '';
      if (reference.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Reference registrasi tidak ditemukan. Ulangi proses.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        _hasNavigated = false;
        if (controller != null && !controller.value.isStreamingImages) {
          _startFaceDetectionStream();
        }
        return;
      }

      setState(() {
        _isUploadingFace = true;
      });

      try {
        if (controller == null || !controller.value.isInitialized) {
          throw Exception('Kamera belum siap untuk mengambil selfie.');
        }

        final image = await controller.takePicture();
        await AuthService.uploadFaceImage(
          File(image.path),
          reference: reference,
          purpose: 'registration',
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isUploadingFace = false;
          });
        }
        _hasNavigated = false;
        if (controller != null && !controller.value.isStreamingImages) {
          _startFaceDetectionStream();
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isUploadingFace = false;
        });
      }

      await _routeAfterFaceVerified();
      return;
    }

    setState(() {
      _isUploadingFace = true;
    });

    try {
      if (controller == null || !controller.value.isInitialized) {
        throw Exception('Kamera belum siap untuk mengambil selfie.');
      }

      final image = await controller.takePicture();
      await AuthService.checkFaceLogin(
        File(image.path),
        reference: widget.reference?.trim(),
        purpose: 'login',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUploadingFace = false;
        });
      }
      _hasNavigated = false;
      if (controller != null && !controller.value.isStreamingImages) {
        _startFaceDetectionStream();
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isUploadingFace = false;
      });
    }

    await _routeAfterFaceVerified();
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      if (controller.value.isStreamingImages) {
        controller.stopImageStream();
      }
      controller.dispose();
    }
    if (!_isDevFaceBypassEnabled) {
      _faceDetector.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(fontWeight: FontWeight.w700);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textBlack,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: _isDevFaceBypassEnabled
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TEKS INSTRUKSI
                  Text(
                    _isUploadingFace
                        ? 'Mengunggah selfie...'
                        : _instructionText(),
                    style: alumniSansBold.copyWith(
                      fontSize: 32,
                      color: AppColors.textBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 60),

                  // WADAH KAMERA (DUMMY FACE)
                  GestureDetector(
                    onTap: _onCaptureTap,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Lingkaran luar (Simulasi garis pinggir seperti di Figma)
                        Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: MediaQuery.of(context).size.width * 0.85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          height: MediaQuery.of(context).size.width * 0.75,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: _errorMessage != null
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Text(
                                        _errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  )
                                : !_isCameraReady || _controller == null
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width:
                                              _controller!
                                                  .value
                                                  .previewSize
                                                  ?.height ??
                                              1,
                                          height:
                                              _controller!
                                                  .value
                                                  .previewSize
                                                  ?.width ??
                                              1,
                                          child: CameraPreview(_controller!),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
      ),
    );
  }
}
