import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HRDPengaturanSistemScreen extends StatefulWidget {
  const HRDPengaturanSistemScreen({super.key});

  @override
  State<HRDPengaturanSistemScreen> createState() => _HRDPengaturanSistemScreenState();
}

class _HRDPengaturanSistemScreenState extends State<HRDPengaturanSistemScreen> {
  bool _autoApprovalEnabled = false;
  bool _emailNotificationEnabled = true;
  bool _weekendSubmissionEnabled = false;
  int _maxDaysAdvance = 30;
  int _minDaysNotice = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5FBF),
        foregroundColor: Colors.white,
        title: Text(
          'Pengaturan Sistem',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pengaturan Umum
              _buildSectionCard(
                'Pengaturan Umum',
                [
                  _buildSwitchTile(
                    'Auto Approval',
                    'Otomatis menyetujui pengajuan cuti tertentu',
                    _autoApprovalEnabled,
                    (value) => setState(() => _autoApprovalEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Notifikasi Email',
                    'Kirim notifikasi email untuk setiap pengajuan',
                    _emailNotificationEnabled,
                    (value) => setState(() => _emailNotificationEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Pengajuan Weekend',
                    'Izinkan pengajuan cuti di akhir pekan',
                    _weekendSubmissionEnabled,
                    (value) => setState(() => _weekendSubmissionEnabled = value),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Pengaturan Waktu
              _buildSectionCard(
                'Pengaturan Waktu',
                [
                  _buildSliderTile(
                    'Maksimal Hari ke Depan',
                    'Batas maksimal pengajuan cuti ke depan',
                    _maxDaysAdvance,
                    1,
                    90,
                    (value) => setState(() => _maxDaysAdvance = value.round()),
                    '${_maxDaysAdvance} hari',
                  ),
                  _buildSliderTile(
                    'Minimal Pemberitahuan',
                    'Minimal hari sebelum tanggal cuti',
                    _minDaysNotice,
                    1,
                    14,
                    (value) => setState(() => _minDaysNotice = value.round()),
                    '${_minDaysNotice} hari',
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Pengaturan Backup
              _buildSectionCard(
                'Backup & Restore',
                [
                  _buildActionTile(
                    'Backup Database',
                    'Buat cadangan data sistem',
                    Icons.backup_outlined,
                    const Color(0xFF4A5FBF),
                    () => _showBackupDialog(),
                  ),
                  _buildActionTile(
                    'Restore Database',
                    'Pulihkan data dari cadangan',
                    Icons.restore_outlined,
                    const Color(0xFFF5B500),
                    () => _showRestoreDialog(),
                  ),
                  _buildActionTile(
                    'Reset Sistem',
                    'Reset semua pengaturan ke default',
                    Icons.refresh_outlined,
                    const Color(0xFFE83C3C),
                    () => _showResetDialog(),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5FBF),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Simpan Pengaturan',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
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
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
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
                Text(
                  subtitle,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4A5FBF),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(String title, String subtitle, int value, int min, int max, Function(double) onChanged, String displayValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
              Text(
                displayValue,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A5FBF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: onChanged,
            activeColor: const Color(0xFF4A5FBF),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
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
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pengaturan berhasil disimpan',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: const Color(0xFF4A5FBF),
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Backup Database',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin membuat backup database? Proses ini mungkin memakan waktu beberapa menit.',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF718096),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Backup database berhasil dibuat',
                    style: GoogleFonts.montserrat(),
                  ),
                  backgroundColor: const Color(0xFF4A5FBF),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A5FBF),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Backup',
              style: GoogleFonts.montserrat(),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Restore Database',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin restore database? Semua data saat ini akan diganti dengan data backup.',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF718096),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Database berhasil direstore',
                    style: GoogleFonts.montserrat(),
                  ),
                  backgroundColor: const Color(0xFFF5B500),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5B500),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Restore',
              style: GoogleFonts.montserrat(),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Reset Sistem',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'PERINGATAN: Tindakan ini akan menghapus SEMUA data dan mengembalikan sistem ke pengaturan default. Tindakan ini tidak dapat dibatalkan!',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF718096),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Sistem berhasil direset',
                    style: GoogleFonts.montserrat(),
                  ),
                  backgroundColor: const Color(0xFFE83C3C),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE83C3C),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Reset',
              style: GoogleFonts.montserrat(),
            ),
          ),
        ],
      ),
    );
  }
}