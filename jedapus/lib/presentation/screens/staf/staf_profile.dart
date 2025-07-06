import 'package:flutter/material.dart';
import 'package:jedapus/presentation/screens/shared/edit_profile_screen.dart';
import 'package:jedapus/presentation/screens/shared/change_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../../core/constants.dart';
import '../../providers.dart';

class StafProfileScreen extends StatelessWidget {
  const StafProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profile
              _buildProfileHeader(),
              
              const SizedBox(height: 24),
              
              // Profile Info Card
              _buildProfileInfoCard(),
              
              const SizedBox(height: 24),
              
              // Menu Options
              _buildMenuOptions(context),
              
              const SizedBox(height: 24),
              
              // Logout Button
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A5FBF), Color(0xFF5B6BC7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // Avatar dengan Base64 support
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: _buildProfileImage(auth),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Nama
              Text(
                auth.currentUser?.namaUser ?? 'Unknown User',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              // NIP
              Text(
                'NIP: ${auth.currentUser?.nip ?? '-'}',
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(AuthProvider auth) {
    final fotoProfil = auth.currentUser?.profilStaf?.fotoProfil;
    
    // Jika ada foto profil dan valid Base64
    if (fotoProfil != null && fotoProfil.isNotEmpty && _isValidBase64(fotoProfil)) {
      try {
        return Image.memory(
          base64Decode(fotoProfil),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar(auth.currentUser?.namaUser ?? "User");
          },
        );
      } catch (e) {
        debugPrint('Error decoding profile image: $e');
        return _buildDefaultAvatar(auth.currentUser?.namaUser ?? "User");
      }
    }
    
    // Fallback ke avatar default
    return _buildDefaultAvatar(auth.currentUser?.namaUser ?? "User");
  }

  bool _isValidBase64(String str) {
    try {
      if (str.length % 4 != 0) {
        return false;
      }
      
      final base64RegExp = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      if (!base64RegExp.hasMatch(str)) {
        return false;
      }
      
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFF5B500),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "U",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final profil = auth.currentUser?.profilStaf;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Personal',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildInfoRow('Jabatan', profil?.jabatan ?? '-'),
              _buildInfoRow('Unit Kerja', profil?.unitKerja ?? '-'),
              _buildInfoRow('Jenis Kelamin', profil?.jenisKelamin == 'L' ? 'Laki-laki' : profil?.jenisKelamin == 'P' ? 'Perempuan' : '-'),
              _buildInfoRow('Tempat Lahir', profil?.tempatLahir ?? '-'),
              _buildInfoRow('Tanggal Lahir', profil?.tanggalLahir != null ? _formatDate(profil!.tanggalLahir!) : '-'),
              _buildInfoRow('No. Telepon', profil?.noTelepon ?? '-'),
              _buildInfoRow('Alamat', profil?.alamat ?? '-'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: const Color(0xFF718096),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: const Color(0xFF2D3748),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Ubah informasi personal',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              
              // Refresh data jika ada perubahan
              if (result == true) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.refreshUser();
              }
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Ubah Password',
            subtitle: 'Ganti password akun',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
              
              // Refresh data jika ada perubahan
              if (result == true) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.refreshUser();
              }
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            subtitle: 'Pengaturan notifikasi',
            onTap: () {
              // Navigate to notification settings
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Bantuan',
            subtitle: 'FAQ dan panduan aplikasi',
            onTap: () {
              // Navigate to help
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4A5FBF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF4A5FBF),
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(///
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF718096),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: const Color(0xFFE5E5E5),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: Text(
          'Logout',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE83C3C),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF718096),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE83C3C),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.montserrat(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      await authProvider.logout();
      
      // Tutup loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Navigate ke login akan otomatis handled oleh app.dart
      // karena auth state berubah
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Berhasil logout',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4A5FBF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      // Tutup loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}
