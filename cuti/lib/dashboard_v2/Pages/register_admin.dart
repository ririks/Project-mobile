import 'package:flutter/material.dart';

class RegisterAdminPage extends StatelessWidget {
  const RegisterAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Register Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField(label: 'Nama Admin', icon: Icons.person, validator: (value) {
              if (value == null || value.isEmpty) return 'Nama tidak boleh kosong';
              return null;
            }),
            const SizedBox(height: 10),
            _buildTextField(label: 'Email', icon: Icons.email, validator: (value) {
              if (value == null || !value.contains('@')) return 'Email tidak valid';
              return null;
            }),
            const SizedBox(height: 10),
            _buildTextField(label: 'Password', icon: Icons.lock, isPassword: true, validator: (value) {
              if (value == null || value.length < 6) return 'Password minimal 6 karakter';
              return null;
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin berhasil didaftarkan')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Daftar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}
