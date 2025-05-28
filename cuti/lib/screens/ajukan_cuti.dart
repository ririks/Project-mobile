import 'package:flutter/material.dart';

class AjukanCutiPage extends StatefulWidget {
  const AjukanCutiPage({super.key});

  @override
  State<AjukanCutiPage> createState() => _AjukanCutiPageState();
}

class _AjukanCutiPageState extends State<AjukanCutiPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tanggalMulaiController = TextEditingController();
  final TextEditingController _tanggalSelesaiController = TextEditingController();
  final TextEditingController _alasanCutiController = TextEditingController();

  String? _selectedJenisCuti;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  bool _isSubmitting = false;

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
  }

  @override
  void dispose() {
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    _alasanCutiController.dispose();
    _buttonAnimationController.dispose(); 
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
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
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF424242), 
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true; 
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isSubmitting = false; 
      });
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          elevation: 0,
          backgroundColor: Colors.transparent, 
          child: Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 45), 
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
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
                  children: <Widget>[
                    const SizedBox(height: 60), 
                    const Text(
                      "Pengajuan Cuti Berhasil!",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF424242),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Cuti Anda telah berhasil diajukan. Silakan tunggu konfirmasi dari atasan Anda.",
                      style: TextStyle(fontSize: 16.0, color: Color(0xFF757575)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); 
                          _tanggalMulaiController.clear();
                          _tanggalSelesaiController.clear();
                          _alasanCutiController.clear();
                          setState(() {
                            _selectedJenisCuti = null;
                          });
                        },
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
              // Posisi ikon di atas dialog
              Positioned(
                left: 20,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFFDD835), 
                  radius: 45, 
                  child: const Icon(
                    Icons.check_circle_outline, 
                    color: Colors.white, 
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0), 
        child: Form(
          key: _formKey, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 30), 
              const Text(
                'Yuk, ajukan cuti biar makin fresh!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Isi detail cuti kamu di bawah ini ya.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // Field Tanggal Mulai Cuti
              _buildTextField(
                controller: _tanggalMulaiController,
                label: 'Tanggal Mulai Cuti',
                hint: 'Pilih tanggal mulai cuti',
                icon: Icons.calendar_today_outlined,
                readOnly: true, 
                onTap: () => _selectDate(context, _tanggalMulaiController), 
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _tanggalSelesaiController,
                label: 'Tanggal Selesai Cuti',
                hint: 'Pilih tanggal selesai cuti',
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () => _selectDate(context, _tanggalSelesaiController),
              ),
              const SizedBox(height: 20),

              _buildDropdownField(
                label: 'Jenis Cuti',
                hint: 'Pilih jenis cuti',
                value: _selectedJenisCuti,
                items: const ['Cuti Tahunan', 'Cuti Sakit', 'Cuti Melahirkan', 'Cuti Penting Lainnya'],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedJenisCuti = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _alasanCutiController,
                label: 'Alasan Cuti',
                hint: 'Jelaskan alasan cuti Anda',
                icon: Icons.edit_note_outlined,
                maxLines: 5, 
              ),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _buttonScaleAnimation, 
                child: Center(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () {
                      _buttonAnimationController.forward().then((_) {
                        _buttonAnimationController.reverse();
                      });
                      _submitForm(); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDD835),
                      foregroundColor: const Color(0xFF424242), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), 
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      elevation: 5, 
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFF424242), 
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Ajukan Sekarang',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
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
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFFDD835)) : null,
            filled: true,
            fillColor: Colors.white, 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFDD835), width: 2), 
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Kolom ini tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.category_outlined, color: Color(0xFFFDD835)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFDD835), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFDD835)),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pilih jenis cuti';
            }
            return null;
          },
        ),
      ],
    );
  }
}