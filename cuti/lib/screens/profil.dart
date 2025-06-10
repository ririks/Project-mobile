import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilPage extends StatefulWidget {
  final int idUser;

  const ProfilPage({super.key, required this.idUser});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _jkController = TextEditingController();
  final TextEditingController _telpController = TextEditingController();
  final TextEditingController _bagianController = TextEditingController();

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeOut),
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final karyawan = await supabase
    .from('karyawan')
    .select()
    .eq('id_karyawan', widget.idUser)
    .single();

final bagian = await supabase
    .from('bagian')
    .select('nm_bag')
    .eq('id_bag', karyawan['id_bag'])
    .single();

setState(() {
  _nikController.text = karyawan['nik'] ?? '';
  _passwordController.text = karyawan['password'] ?? '';
  _namaController.text = karyawan['nm_karyawan'] ?? '';
  _alamatController.text = karyawan['alamat'] ?? '';
  _jkController.text = karyawan['j_kel'] ?? '';
  _telpController.text = karyawan['telp'] ?? '';
  _bagianController.text = bagian['nm_bag'] ?? '';
  _isLoading = false;
});

    } catch (e) {
      print('Gagal mengambil data karyawan: $e');
      setState(() => _isLoading = false);
    }
  }

  void _handleLogout() {
    _buttonAnimationController.forward().then((_) => _buttonAnimationController.reverse());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anda telah berhasil logout!'),
                    backgroundColor: Color(0xFFFDD835),
                  ),
                );
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  String getInitials(String name) {
  List<String> parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
  } else if (parts.isNotEmpty) {
    return parts[0][0].toUpperCase();
  }
  return '';
}

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _passwordController.dispose();
    _alamatController.dispose();
    _jkController.dispose();
    _telpController.dispose();
    _bagianController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFDD835)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                 CircleAvatar(
  radius: 60,
  backgroundColor: const Color(0xFFFDD835),
  child: Text(
    getInitials(_namaController.text),
    style: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
),

                  const SizedBox(height: 50),
                  Text(
                    _namaController.text,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  const Text('Status: Aktif', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 30),

                  _buildInfoField(controller: _nikController, label: 'NIK', icon: Icons.badge_outlined),
                  const SizedBox(height: 20),
                  _buildInfoField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, obscureText: true),
                  const SizedBox(height: 20),
                  _buildInfoField(controller: _alamatController, label: 'Alamat', icon: Icons.home_outlined),
                  const SizedBox(height: 20),
                  _buildInfoField(controller: _jkController, label: 'Jenis Kelamin', icon: Icons.person_2_outlined),
                  const SizedBox(height: 20),
                  _buildInfoField(controller: _telpController, label: 'Telepon', icon: Icons.phone_outlined),
                  const SizedBox(height: 20),
                  _buildInfoField(controller: _bagianController, label: 'Bagian', icon: Icons.work_outline),

                  const SizedBox(height: 40),
                  ScaleTransition(
                    scale: _buttonScaleAnimation,
                    child: ElevatedButton(
                      onPressed: _handleLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: const Text('Logout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFFDD835)) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
