import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as ml;
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'qris_konfirmasi_screen.dart';
import '../../../api/banking.dart';

class QrisScreen extends StatefulWidget {
  const QrisScreen({super.key});

  @override
  State<QrisScreen> createState() => _QrisScreenState();
}

class _QrisScreenState extends State<QrisScreen> {
  final ms.MobileScannerController _scannerController =
      ms.MobileScannerController(
        detectionSpeed: ms.DetectionSpeed.noDuplicates,
        facing: ms.CameraFacing.back,
      );

  bool _isScannerActive = false;
  bool _isHandlingScan = false;

  void _trace(String message) {
    debugPrint(message);
  }

  String? _extractMsBarcodeValue(List<ms.Barcode> barcodes) {
    for (final barcode in barcodes) {
      final raw = (barcode.rawValue ?? '').trim();
      if (raw.isNotEmpty) return raw;
      final display = (barcode.displayValue ?? '').trim();
      if (display.isNotEmpty) return display;
    }
    return null;
  }

  String? _extractMlBarcodeValue(List<ml.Barcode> barcodes) {
    for (final barcode in barcodes) {
      final raw = (barcode.rawValue ?? '').trim();
      if (raw.isNotEmpty) return raw;
      final display = (barcode.displayValue ?? '').trim();
      if (display.isNotEmpty) return display;
    }
    return null;
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleScannedValue(String? value) async {
    final qrisValue = value?.trim() ?? '';
    if (qrisValue.isEmpty || _isHandlingScan || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR tidak valid. Coba lagi.'), backgroundColor: Colors.red),
      );
      return;
    }

    _isHandlingScan = true;
    final wasScannerActive = _isScannerActive;
    if (wasScannerActive) {
      try {
        await _scannerController.stop();
      } catch (_) {
        // Ignore stop errors so QRIS API call can still proceed.
      }
    }

    if (!mounted) {
      _isHandlingScan = false;
      _trace('[QRIS] widget not mounted after stop scanner');
      return;
    }
    late final Map<String, dynamic> qrisDetail;
    try {
      qrisDetail = await BankingService.checkQris(qrisNumber: qrisValue);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memproses QRIS. Coba lagi.'), backgroundColor: Colors.red),
      );
      _isHandlingScan = false;
      if (wasScannerActive) {
        try {
          await _scannerController.start();
        } catch (_) {
          // Ignore restart errors and let user tap scan again.
        }
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrisKonfirmasiScreen(
          qrisNumber: qrisValue,
          merchantName: qrisDetail['merchant_name'] ?? 'Unknown Merchant',
          location: qrisDetail['location'] ?? 'Unknown Location',
          aquirer: qrisDetail['aquirer'] ?? 'Unknown Acquirer',
          panId: qrisDetail['PAN_id'] ?? 'Unknown PAN ID',
        ),
      ),
    ).then((_) async {
      if (!mounted) return;
      _isHandlingScan = false;
      if (_isScannerActive) {
        await _scannerController.start();
      }
    });
  }

  Future<void> _startScan() async {
    if (_isScannerActive) return;
    setState(() {
      _isScannerActive = true;
      _isHandlingScan = false;
    });
    await _scannerController.start();
  }

  Future<void> _pickAndScanFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (!mounted || image == null) return;

    final ml.BarcodeScanner barcodeScanner = ml.BarcodeScanner();
    String? firstValue;
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final barcodes = await barcodeScanner.processImage(inputImage);
      firstValue = _extractMlBarcodeValue(barcodes);
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Plugin scanner belum aktif. Stop app lalu jalankan ulang (full restart).',
          ),
        ),
      );
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memproses gambar: $e'), backgroundColor: Colors.red));
      return;
    } finally {
      try {
        await barcodeScanner.close();
      } catch (_) {
        // Ignore close failures when plugin is not initialized yet.
      }
    }

    if (!mounted) return;

    if (firstValue == null || firstValue.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR tidak ditemukan pada foto yang dipilih.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await _handleScannedValue(firstValue);
  }

  @override
  Widget build(BuildContext context) {
    Color transparentAppBarColor = const Color(0x1AFFCA96);
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: transparentAppBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "QRIS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            fontFamily: 'AlumniSans',
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFEBEBEB),
                  child: _isScannerActive
                      ? ms.MobileScanner(
                          controller: _scannerController,
                          onDetect: (capture) {
                            final first = _extractMsBarcodeValue(
                              capture.barcodes,
                            );
                            _handleScannedValue(first);
                          },
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              size: 100,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Tap 'Scan QR' untuk mulai membaca kode",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),

                SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _buildCornerLine(isTop: true, isLeft: true),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _buildCornerLine(isTop: true, isLeft: false),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: _buildCornerLine(isTop: false, isLeft: true),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _buildCornerLine(isTop: false, isLeft: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _startScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7F00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Scan QR",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _pickAndScanFromGallery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7F00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Upload File",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerLine({required bool isTop, required bool isLeft}) {
    const double length = 55.0;
    const double strokeWidth = 12.0;
    const Radius radius = Radius.circular(16.0);

    return Container(
      width: length,
      height: length,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? const BorderSide(color: Colors.black, width: strokeWidth)
              : BorderSide.none,
          bottom: !isTop
              ? const BorderSide(color: Colors.black, width: strokeWidth)
              : BorderSide.none,
          left: isLeft
              ? const BorderSide(color: Colors.black, width: strokeWidth)
              : BorderSide.none,
          right: !isLeft
              ? const BorderSide(color: Colors.black, width: strokeWidth)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: (isTop && isLeft) ? radius : Radius.zero,
          topRight: (isTop && !isLeft) ? radius : Radius.zero,
          bottomLeft: (!isTop && isLeft) ? radius : Radius.zero,
          bottomRight: (!isTop && !isLeft) ? radius : Radius.zero,
        ),
      ),
    );
  }
}
