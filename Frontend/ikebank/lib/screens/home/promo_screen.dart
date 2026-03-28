import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import '../../../core/colors.dart'; 
import 'promo_detail_screen.dart'; 

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle alumniSansBold = const TextStyle(
      fontWeight: FontWeight.w700,
      fontFamily: 'AlumniSans',
    );

    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        toolbarHeight: 80, 
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
        
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 0.5),
            Image.asset(
              'assets/images/IKEHome.png',
              height: 50,
              fit: BoxFit.contain,
            ),
          ],
        ),
        centerTitle: false,
        
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20),
            icon: SvgPicture.asset(
              'assets/images/lainnya.svg',
              height: 40,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 0.5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PromoDetailScreen()),
                  );
                },
                child: ClipRRect(
                  child: Image.asset(
                    'assets/images/promo.png',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 15), 

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0), 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), 
                border: Border.all(color: Colors.grey.shade400, width: 1.0), 
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4), 
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PromoDetailScreen()),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ikutan Deposito dadakan dan dapatkan bunga hingga 8.8% p.a",
                          style: alumniSansBold.copyWith(fontSize: 20, color: Colors.black, height: 1.1),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Nikmati Bunga hingga 8.8% hanya di IKE Bank!!!!",
                          style: TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Lihat Detail",
                          style: TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text("Pencarian & Filter", style: alumniSansBold.copyWith(fontSize: 22, color: Colors.black)),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.black54),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: AppColors.primaryOrange),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), 
                    padding: EdgeInsets.zero, 
                    itemCount: 2, 
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PromoDetailScreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("IKE Bank", style: alumniSansBold.copyWith(fontSize: 16, color: Colors.black)),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 180,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade200), 
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                  'assets/images/promo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40), // Jarak ekstra di bagian paling bawah
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}