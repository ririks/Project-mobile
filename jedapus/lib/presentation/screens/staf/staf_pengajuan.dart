import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../../providers.dart';

class StafPengajuanScreen extends StatefulWidget {
  const StafPengajuanScreen({super.key});

  @override
  State<StafPengajuanScreen> createState() => _StafPengajuanScreenState();
}

class _StafPengajuanScreenState extends State<StafPengajuanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alasanController = TextEditingController();

  String _selectedJenisCuti = 'Cuti Tahunan';
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  bool _isSubmitting = false;

  final List<String> _jenisCutiOptions = [
    'Cuti Tahunan',
    'Cuti Sakit',
    'Cuti Lainnya',
  ];

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Consumer<CutiProvider>(
    builder: (context, cutiProvider, child) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),
                
                // Error message jika ada
                if (cutiProvider.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE83C3C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE83C3C)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: const Color(0xFFE83C3C),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cutiProvider.error!,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: const Color(0xFFE83C3C),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => cutiProvider.clearError(),
                        ),
                      ],
                    ),
                  ),
                
                // Form Card
                _buildFormCard(),
                const SizedBox(height: 24),
                
                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  Widget _buildHeader() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajukan Cuti',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Isi form di bawah untuk mengajukan cuti',
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Jenis Cuti Dropdown
            _buildSectionTitle('Jenis Cuti'),
            const SizedBox(height: 8),
            _buildDropdown(),

            const SizedBox(height: 20),

            // Tanggal Mulai
            _buildSectionTitle('Tanggal Mulai'),
            const SizedBox(height: 8),
            _buildDateField(
              'Pilih tanggal mulai',
              _tanggalMulai,
              (date) => setState(() => _tanggalMulai = date),
            ),

            const SizedBox(height: 20),

            // Tanggal Selesai
            _buildSectionTitle('Tanggal Selesai'),
            const SizedBox(height: 8),
            _buildDateField(
              'Pilih tanggal selesai',
              _tanggalSelesai,
              (date) => setState(() => _tanggalSelesai = date),
            ),

            const SizedBox(height: 20),

            // Durasi (Auto calculated)
            if (_tanggalMulai != null && _tanggalSelesai != null)
              _buildDurasiInfo(),

            const SizedBox(height: 20),

            // Alasan
            _buildSectionTitle('Alasan Cuti'),
            const SizedBox(height: 8),
            _buildAlasanField(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedJenisCuti,
          isExpanded: true,
          items: _jenisCutiOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: const Color(0xFF2D3748),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedJenisCuti = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDateField(
      String hint, DateTime? selectedDate, Function(DateTime) onDateSelected) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: const Color(0xFF4A5FBF),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null ? _formatDate(selectedDate) : hint,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: selectedDate != null
                      ? const Color(0xFF2D3748)
                      : const Color(0xFF718096),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurasiInfo() {
    final durasi = _tanggalSelesai!.difference(_tanggalMulai!).inDays + 1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5FBF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFF4A5FBF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Durasi cuti: $durasi hari',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A5FBF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlasanField() {
    return TextFormField(
      controller: _alasanController,
      maxLines: 4,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Alasan cuti harus diisi';
        }
        if (value.trim().length < 10) {
          return 'Alasan minimal 10 karakter';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Jelaskan alasan pengajuan cuti Anda...',
        hintStyle: GoogleFonts.montserrat(
          color: const Color(0xFF718096),
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A5FBF)),
        ),
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
      ),
      style: GoogleFonts.montserrat(
        fontSize: 14,
        color: const Color(0xFF2D3748),
      ),
    );
  }

  Widget _buildSubmitButton() {
  return Consumer<CutiProvider>(
    builder: (context, cutiProvider, child) {
      final isLoading = cutiProvider.isLoading || _isSubmitting;
      
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : _submitPengajuan,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A5FBF),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  'Ajukan Cuti',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      );
    },
  );
}

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  void _submitPengajuan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tanggalMulai == null || _tanggalSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih tanggal mulai dan selesai',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: const Color(0xFFE83C3C),
        ),
      );
      return;
    }

    if (_tanggalSelesai!.isBefore(_tanggalMulai!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tanggal selesai tidak boleh sebelum tanggal mulai',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: const Color(0xFFE83C3C),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Ambil user ID dari AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        throw Exception('User tidak ditemukan');
      }

      // Gunakan CutiProvider untuk menyimpan ke database
      final cutiProvider = Provider.of<CutiProvider>(context, listen: false);

      final success = await cutiProvider.createPengajuan(
        userId: currentUser.uuidUser,
        jenisCuti: _selectedJenisCuti,
        tanggalMulai: _tanggalMulai!,
        tanggalSelesai: _tanggalSelesai!,
        alasan: _alasanController.text.trim(),
      );

      if (success && mounted) {
        // Berhasil menyimpan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengajuan cuti berhasil dikirim dan disimpan ke database',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFF4A5FBF),
          ),
        );

        // Reset form
        _alasanController.clear();
        setState(() {
          _selectedJenisCuti = 'Cuti Tahunan';
          _tanggalMulai = null;
          _tanggalSelesai = null;
        });

        // Refresh dashboard data jika ada
        final dashboardProvider =
            Provider.of<DashboardProvider>(context, listen: false);
        dashboardProvider.refresh(currentUser.uuidUser, currentUser.role);
      } else {
        // Gagal menyimpan
        final errorMessage = cutiProvider.error ?? 'Gagal menyimpan pengajuan';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: const Color(0xFFE83C3C),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan: $e',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFE83C3C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
