import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../api/banking.dart';
import '../../models/account_detail.dart';
import '../../../core/colors.dart';

class TambahDanaScreen extends StatefulWidget {
  const TambahDanaScreen({super.key});

  @override
  State<TambahDanaScreen> createState() => _TambahDanaScreenState();
}

class _TambahDanaScreenState extends State<TambahDanaScreen> {
  AccountDetail? _primaryAccount;

  @override
  void initState() {
    super.initState();
    _loadPrimaryAccount();
  }

  Future<void> _loadPrimaryAccount() async {
    try {
      final accountDetails = await BankingService.fetchAccountDetails();
      if (!mounted) {
        return;
      }
      setState(() {
        _primaryAccount = accountDetails.isNotEmpty ? accountDetails.first : null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: 'AlumniSans',
    );

    final String safeAccountName = (_primaryAccount?.username.trim().isNotEmpty ?? false)
      ? _primaryAccount!.username.trim()
        : 'Pengguna';
    final String safeAccountNumber = (_primaryAccount?.accountnumber.trim().isNotEmpty ?? false)
      ? _primaryAccount!.accountnumber.trim()
        : '-';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Tambah Dana",
          style: alumniSansBold.copyWith(fontSize: 28, color: Colors.black),
        ),
      ),
      //error
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCD6FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/IKEHome.png',
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              safeAccountName,
                              style: alumniSansBold.copyWith(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            const Text(
                              "Saku Utama",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(
                    height: 1,
                    color: Color(0xFFEEEEEE),
                    thickness: 1.5,
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF9F2),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Nomor rekening Saku",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              safeAccountNumber,
                              style: alumniSansBold.copyWith(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: safeAccountNumber),
                            ).then((_) {});
                          },
                          child: SvgPicture.asset(
                            'assets/images/copy.svg',
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              AppColors.primaryOrange,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              "Cara top up",
              style: alumniSansBold.copyWith(fontSize: 20, color: Colors.black),
            ),
            const SizedBox(height: 16),

            _buildTopUpMethod(
              icon: Icons.phone_iphone,
              title: "Aplikasi Banking",
            ),
            _buildTopUpMethod(icon: Icons.wifi, title: "Internet Banking"),
            _buildTopUpMethod(
              icon: Icons.chat_bubble_outline,
              title: "SMS Banking",
            ),
            _buildTopUpMethod(icon: Icons.local_atm, title: "ATM"),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpMethod({required IconData icon, required String title}) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: 'AlumniSans',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryOrange, size: 28),
          const SizedBox(width: 20),
          Text(
            title,
            style: alumniSansBold.copyWith(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
