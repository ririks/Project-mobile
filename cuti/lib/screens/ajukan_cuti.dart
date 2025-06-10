import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AjukanCutiPage extends StatefulWidget {
  final int idUser;

  const AjukanCutiPage({super.key, required this.idUser});

  @override
  State<AjukanCutiPage> createState() => _AjukanCutiPageState();
}

class _AjukanCutiPageState extends State<AjukanCutiPage> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tanggalMulaiController = TextEditingController();
  final TextEditingController _tanggalSelesaiController = TextEditingController();
  final TextEditingController _alasanCutiController = TextEditingController();

  String? _selectedJenisCuti;
  String? _nmKaryawan;
  String? _nik;
  String? _bagian;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  bool _isSubmitting = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final karyawan = await supabase
          .from('karyawan')
          .select('nik, nm_karyawan, id_bag')
          .eq('id_karyawan', widget.idUser)
          .single();

      final bagian = await supabase
          .from('bagian')
          .select('nm_bag')
          .eq('id_bag', karyawan['id_bag'])
          .single();

      setState(() {
        _nik = karyawan['nik'];
        _nmKaryawan = karyawan['nm_karyawan'];
        _bagian = bagian['nm_bag'];
        _isLoading = false;
      });
    } catch (e) {
      print('Gagal load data user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data pengguna: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFDD835),
              onPrimary: Color(0xFF424242),
              onSurface: Color(0xFF424242),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF424242)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  String _formatDateToISO(String dateString) {
    List<String> parts = dateString.split('/');
    if (parts.length == 3) {
      String day = parts[0].padLeft(2, '0');
      String month = parts[1].padLeft(2, '0');
      String year = parts[2];
      return '$year-$month-$day';
    }
    return dateString; 
  }


  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_nmKaryawan == null || _nik == null || _bagian == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data pengguna. Coba lagi.')),
        );
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        final String tanggalMulaiISO = _formatDateToISO(_tanggalMulaiController.text);
        final String tanggalSelesaiISO = _formatDateToISO(_tanggalSelesaiController.text);

        final dataToInsert = {
          'tgl': DateTime.now().toIso8601String().split('T').first, // Ini sudah benar format YYYY-MM-DD
          'nik': _nik,
          'nm_karyawan': _nmKaryawan,
          'nm_cuti': _selectedJenisCuti,
          'bagian': _bagian,
          'id_karyawan': widget.idUser,
          'alasan': _alasanCutiController.text,
          'tgl_mulai': tanggalMulaiISO,     
          'tgl_selesai': tanggalSelesaiISO, 
        };

        await supabase.from('cuti').insert(dataToInsert);

        if (mounted) {
          _showSuccessDialog();
          _formKey.currentState?.reset();
          _tanggalMulaiController.clear();
          _tanggalSelesaiController.clear();
          _alasanCutiController.clear();
          setState(() => _selectedJenisCuti = null);
        }
      } on PostgrestException catch (e) {
        print('Gagal submit cuti (PostgrestException): ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengajukan cuti: ${e.message}')),
          );
        }
      } catch (e) {
        print('Gagal submit cuti (General Exception): $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan tidak terduga saat mengajukan cuti: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
          Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 60),
              const Text(
                "Pengajuan Cuti Berhasil!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF424242),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                "Cuti Anda telah berhasil diajukan. Silakan tunggu konfirmasi dari atasan Anda.",
                style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Oke",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFFDD835),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Color(0xFFFDD835),
            radius: 45,
            child: Icon(Icons.check_circle_outline, color: Colors.white, size: 50),
          ),
        ),
        ],
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFDD835)),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10), 
              Text(
                'Ajukan Cuti untuk ${_nmKaryawan ?? 'Nama Karyawan'}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 10),
              Text('Bagian: ${_bagian ?? 'Bagian Tidak Diketahui'}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              const SizedBox(height: 30),
              _buildTextField(
                controller: _tanggalMulaiController,
                label: 'Tanggal Mulai Cuti',
                hint: 'Pilih tanggal mulai cuti (DD/MM/YYYY)',
                icon: Icons.calendar_today_outlined,
                readOnly: true, // Kembali ke readOnly true agar user wajib pakai date picker
                onTap: () => _selectDate(context, _tanggalMulaiController),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _tanggalSelesaiController,
                label: 'Tanggal Selesai Cuti',
                hint: 'Pilih tanggal selesai cuti (DD/MM/YYYY)',
                icon: Icons.calendar_today_outlined,
                readOnly: true, // Kembali ke readOnly true
                onTap: () => _selectDate(context, _tanggalSelesaiController),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedJenisCuti,
                decoration: InputDecoration(
                  labelText: 'Jenis Cuti',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: [
                  'Cuti Tahunan',
                  'Cuti Sakit',
                  'Cuti Melahirkan',
                  'Cuti Gugur Kandungan',
                  'Cuti Besar'
                ].map((jenis) {
                  return DropdownMenuItem<String>(
                    value: jenis,
                    child: Text(jenis),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedJenisCuti = value),
                validator: (value) => value == null || value.isEmpty ? 'Harap pilih jenis cuti' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _alasanCutiController,
                label: 'Alasan Cuti',
                hint: 'Tuliskan alasan cuti Anda',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ScaleTransition(
                  scale: _buttonScaleAnimation,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDD835),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      elevation: 5,
                    ),
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Ajukan Cuti',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? 'Harap isi $label' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  @override
  void dispose() {
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    _alasanCutiController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }
}