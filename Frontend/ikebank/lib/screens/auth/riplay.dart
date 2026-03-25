import 'package:flutter/material.dart';
import '../../core/colors.dart';

class RiplayScreen extends StatelessWidget {
  const RiplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryOrange, 
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context), 
        ),
        title: const Text(
          "RIPLAY IKE Bank",
          style: TextStyle(
            fontWeight: FontWeight.w700, 
            color: Colors.white,
            fontSize: 26,
          ),
        ),
        centerTitle: true, 
      ),

      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 10), 
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Scrollbar(
            thumbVisibility: true, 
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40), 
              child: Text(
                "Nama Penerbit : PT IKE Bank Indonesia\n\n"
                "Nama Produk : Saku Utama\n"
                "Jenis Produk : Tabungan\n"
                "Mata Uang : Rupiah\n\n"
                "Deskripsi Produk : Saku yang aktif setelah Nasabah menyelesaikan semua tahapan pembukaan Rekening Digital. Fungsi Saku Utama adalah sebagai Saku yang dapat menerima dana dari bank lain atau sesama Nasabah, melakukan pindah dana dari dan ke Saku Nabung serta Saku Transaksi, dan melakukan Transfer Dana ke bank lain atau ke sesama Nasabah.\n\n"
                "Fitur Utama\n\n"
                "Periode Pembayaran Bunga : Bulanan\n"
                "Suku Bunga : Informasi terkait suku bunga tersedia di situs Rates | IKE Bank\n"
                "Manfaat\n\n"
                "Nasabah dapat menerima dana dari Saku Nabung, Saku Transaksi, Saku Celengan (setelah mencapai jumlah minimal), dan rekening lain\n"
                "Nasabah dapat pindah dana ke Saku Nabung serta Saku Transaksi.\n"
                "Nasabah dapat melakukan transfer dana ke bank lain atau ke sesama Nasabah.\n"
                "Nasabah dapat dengan mudah melakukan kegiatan transaksi di Saku Utama serta memperoleh informasi atas transaksi tersebut.",
                textAlign: TextAlign.justify, 
                style: const TextStyle(
                  fontSize: 18, 
                  color: AppColors.textBlack,
                  height: 1.4, 
                  fontWeight: FontWeight.w400, 
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}