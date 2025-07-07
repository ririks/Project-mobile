import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bantuan & Panduan',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4A5FBF),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'FAQ (Pertanyaan yang Sering Ditanyakan)',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A5FBF),
            ),
          ),
          const SizedBox(height: 12),
          _buildFAQSection(),
          const SizedBox(height: 32),
          Text(
            'Panduan Penggunaan Aplikasi',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4A5FBF),
            ),
          ),
          const SizedBox(height: 12),
          _buildGuideSection(),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      children: [
        ExpansionTile(
          title: Text('Bagaimana cara login ke aplikasi?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          children: [
            ListTile(
              title: Text(
                'Masukkan NIP dan password Anda pada halaman login, lalu tekan tombol "Login". Jika data benar, Anda akan masuk ke dashboard.',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Bagaimana jika lupa password?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          children: [
            ListTile(
              title: Text(
                'Silakan hubungi admin HRD untuk reset password. Fitur reset otomatis belum tersedia.',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Bagaimana cara mengganti password?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          children: [
            ListTile(
              title: Text(
                'Buka menu "Ganti Password", masukkan NIP, password lama, dan password baru. Pastikan password lama benar agar bisa mengganti password.',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Bagaimana mengajukan cuti?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          children: [
            ListTile(
              title: Text(
                'Pilih menu "Pengajuan Cuti", isi form pengajuan sesuai kebutuhan, lalu tekan "Ajukan". Pengajuan akan diproses oleh atasan/HRD.',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Bagaimana melihat sisa cuti?', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
          children: [
            ListTile(
              title: Text(
                'Sisa cuti dapat dilihat di halaman dashboard atau pada menu "Hak Cuti".',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuideSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. Login',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        Text(
          'Masukkan NIP dan password, lalu tekan "Login".',
          style: GoogleFonts.montserrat(),
        ),
        const SizedBox(height: 12),
        Text(
          '2. Melihat Dashboard',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        Text(
          'Dashboard menampilkan ringkasan cuti, pengajuan terakhir, dan notifikasi penting.',
          style: GoogleFonts.montserrat(),
        ),
        const SizedBox(height: 12),
        Text(
          '3. Mengajukan Cuti',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        Text(
          'Pilih menu "Pengajuan Cuti", isi data cuti, lalu tekan "Ajukan".',
          style: GoogleFonts.montserrat(),
        ),
        const SizedBox(height: 12),
        Text(
          '4. Ganti Password',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        Text(
          'Buka menu "Ganti Password", masukkan NIP, password lama, dan password baru.',
          style: GoogleFonts.montserrat(),
        ),
        const SizedBox(height: 12),
        Text(
          '5. Update Profil',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        Text(
          'Edit data profil di menu "Profil" dan simpan perubahan.',
          style: GoogleFonts.montserrat(),
        ),
        const SizedBox(height: 12),
        Text(
          '6. Notifikasi',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        Text(
          'Cek notifikasi untuk informasi terbaru terkait cuti dan status pengajuan.',
          style: GoogleFonts.montserrat(),
        ),
      ],
    );
  }
}
