import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nipController = TextEditingController();
  final _prevPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isPrevPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nipController.dispose();
    _prevPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (bisa pakai _buildBackground() dari LoginScreen)
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _buildLogo(),
                      const SizedBox(height: 20),
                      Text(
                        'GANTI PASSWORD',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A5FBF),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildChangePasswordForm(),
                      const Spacer(),
                      _buildFooter(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    // Bisa copy dari LoginScreen
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8EAF6),
            Color(0xFFF3E5F5),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // Bisa copy dari LoginScreen
    return SizedBox(
      width: 120,
      height: 120,
      child: Image.asset(
        'assets/images/global.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildChangePasswordForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NIP
            Text('NIP', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nipController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '12345678',
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4A5FBF)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'NIP tidak boleh kosong';
                if (value.length < 8) return 'NIP minimal 8 digit';
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Previous Password
            Text('Previous Password', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _prevPasswordController,
              obscureText: !_isPrevPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Password lama',
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4A5FBF)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPrevPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF718096),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPrevPasswordVisible = !_isPrevPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password lama tidak boleh kosong';
                return null;
              },
            ),
            const SizedBox(height: 20),
            // New Password
            Text('New Password', style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newPasswordController,
              obscureText: !_isNewPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Password baru',
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF4A5FBF)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF718096),
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password baru tidak boleh kosong';
                if (value.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 32),
            // Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5FBF),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Ganti Password',
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Developed by Trikandi',
      style: GoogleFonts.montserrat(
        fontSize: 12,
        color: Colors.white.withOpacity(0.8),
      ),
      textAlign: TextAlign.center,
    );
  }

  void _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Cek previous password valid
      final isPrevPasswordValid = await authProvider.checkPassword(
        _nipController.text.trim(),
        _prevPasswordController.text.trim(),
      );

      if (!isPrevPasswordValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password lama salah!'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Ganti password
      final success = await authProvider.changePassword(
        _nipController.text.trim(),
        _newPasswordController.text.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password berhasil diganti!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reset form
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengganti password!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
