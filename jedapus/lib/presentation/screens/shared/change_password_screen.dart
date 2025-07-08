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
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      const SizedBox(height: 40), // Dikurangi dari 60 ke 40 (-20px)
                      _buildLogo(),
                      const SizedBox(height: 12), // Dikurangi dari 20 ke 12 (-8px)
                      Text(
                        'GANTI PASSWORD',
                        style: GoogleFonts.montserrat(
                          fontSize: 22, // Dikurangi dari 24 ke 22
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A5FBF),
                        ),
                      ),
                      const SizedBox(height: 28), // Dikurangi dari 40 ke 28 (-12px)
                      _buildChangePasswordForm(),
                      const Spacer(),
                      _buildFooter(),
                      const SizedBox(height: 25), // Dikurangi dari 40 ke 25 (-15px)
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
    return SizedBox(
      width: 100, 
      height: 100, 
      child: Image.asset(
        'assets/images/global.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildChangePasswordForm() {
    return Container(
      padding: const EdgeInsets.all(24), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15, 
            offset: const Offset(0, 8), 
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NIP
            Text(
              'NIP',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 14, 
              ),
            ),
            const SizedBox(height: 6), 
            TextFormField(
              controller: _nipController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.montserrat(fontSize: 14), 
              decoration: InputDecoration(
                hintText: '12345678',
                hintStyle: GoogleFonts.montserrat(fontSize: 14),
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF4A5FBF), size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), 
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'NIP tidak boleh kosong';
                if (value.length < 8) return 'NIP minimal 8 digit';
                return null;
              },
            ),
            const SizedBox(height: 16), 
            
            // Previous Password
            Text(
              'Previous Password',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6), 
            TextFormField(
              controller: _prevPasswordController,
              obscureText: !_isPrevPasswordVisible,
              style: GoogleFonts.montserrat(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Password lama',
                hintStyle: GoogleFonts.montserrat(fontSize: 14),
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF4A5FBF), size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPrevPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF718096),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPrevPasswordVisible = !_isPrevPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password lama tidak boleh kosong';
                return null;
              },
            ),
            const SizedBox(height: 16), 
            
            // New Password
            Text(
              'New Password',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6), // Dikurangi dari 8 ke 6
            TextFormField(
              controller: _newPasswordController,
              obscureText: !_isNewPasswordVisible,
              style: GoogleFonts.montserrat(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Password baru',
                hintStyle: GoogleFonts.montserrat(fontSize: 14),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF4A5FBF), size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF718096),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password baru tidak boleh kosong';
                if (value.length < 6) return 'Password minimal 6 karakter';
                return null;
              },
            ),
            const SizedBox(height: 24), // Dikurangi dari 32 ke 24
            
            // Button
            SizedBox(
              width: double.infinity,
              height: 48, // Dikurangi dari 56 ke 48
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5FBF),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Dikurangi dari 16 ke 12
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Ganti Password',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // Tambahkan ukuran font
                        ),
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
        fontSize: 11, // Dikurangi dari 12 ke 11
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Password lama salah!',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
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

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Password berhasil diganti!',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Reset form
          _formKey.currentState!.reset();
          _nipController.clear();
          _prevPasswordController.clear();
          _newPasswordController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal mengganti password!',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan. Silakan coba lagi.',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
