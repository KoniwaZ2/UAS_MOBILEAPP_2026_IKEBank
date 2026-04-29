import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../models/register_flow_data.dart';
import 'face_recog_screen.dart';

class VerifikasiWajahScreen extends StatelessWidget {
  final bool isFromRegister;
  final String? email;
  final String? reference;
  final RegisterFlowData? flowData;
  final bool isLupaPin;
  final Map<String, dynamic>? qrisData;

  const VerifikasiWajahScreen({
    super.key,
    this.isFromRegister = false,
    this.email,
    this.reference,
    this.flowData,
    this.isLupaPin = false,
    this.qrisData,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle alumniSansBold = TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: 'AlumniSans', 
    );

    return Scaffold(
      backgroundColor: AppColors.primaryOrange,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: isLupaPin
            ? Text(
                "Lupa PIN",
                style: alumniSansBold.copyWith(
                  fontSize: 28,
                  color: Colors.white,
                ),
              )
            : null,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Verifikasi Wajah",
                          style: alumniSansBold.copyWith(
                            fontSize: 32,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Yuk, ikuti panduan di bawah sebelum verifikasi\nwajahmu",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textBlack,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),

                        Text(
                          "Pastikan:",
                          style: alumniSansBold.copyWith(
                            fontSize: 20,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 24,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEDD8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGuidelineItem(
                                mainIcon: Icons.masks_outlined,
                                hasRedSlash: true,
                                text: "Wajahmu tidak tertutup apa pun",
                              ),
                              const SizedBox(height: 20),

                              _buildGuidelineItem(
                                mainIcon: Icons.wb_sunny_outlined,
                                hasRedSlash: false,
                                text: "Kamu ada di tempat yang terang",
                              ),
                              const SizedBox(height: 20),

                              _buildGuidelineItem(
                                mainIcon: Icons.group_outlined,
                                hasRedSlash: true,
                                text: "Tidak ada orang lain di dalam foto",
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FaceRecogScreen(
                                    isFromRegister: isFromRegister,
                                    email: email,
                                    reference: reference,
                                    flowData: flowData,
                                    isLupaPin: isLupaPin,
                                    qrisData: qrisData,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Ambil selfie",
                              style: alumniSansBold.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGuidelineItem({
    required IconData mainIcon,
    required bool hasRedSlash,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Icon(mainIcon, color: AppColors.primaryOrange, size: 28),
              ),
              if (hasRedSlash)
                const Align(
                  alignment: Alignment.topRight,
                  child: Icon(Icons.block, color: Colors.red, size: 16),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.textBlack,
              ),
            ),
          ),
        ),
      ],
    );
  }
}