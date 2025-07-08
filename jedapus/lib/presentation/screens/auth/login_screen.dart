import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nipController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nipController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background dengan wave
          _buildBackground(),
          
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 53,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      
                      // Logo
                      _buildLogo(),
                      
                      const SizedBox(height: 15),
                      
                      // Title
                      _buildTitle(),
                      
                      const SizedBox(height: 40),
                      
                      // Login Form
                      _buildLoginForm(),
                      
                      const Spacer(),
                      
                      // Footer
                      _buildFooter(),
                      
                      const SizedBox(height: 25),
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
            Color(0xFFE8EAF6), // Light blue-grey
            Color(0xFFF3E5F5), // Light purple
          ],
        ),
      ),
      child: Stack(
        children: [
          // Wave shape - lebih ke atas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4A5FBF), // Main blue
                      Color(0xFF5B6BC7), // Lighter blue
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

  Widget _buildLogo() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Image.asset(
        'assets/images/global.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback jika logo tidak ditemukan
          return const Icon(
            Icons.school,
            size: 60,
            color: Color(0xFF4A5FBF),
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'JEDAPUS',
      style: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF4A5FBF),
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            // Login Title
            Center(
              child: Text(
                'LOGIN',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A5FBF),
                  letterSpacing: 1,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // NIP Field
            Text(
              'NIP',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            _buildNIPField(),
            
            const SizedBox(height: 16),
            
            // Password Field
            Text(
              'Password',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            _buildPasswordField(),
            
            const SizedBox(height: 24),
            
            // Login Button
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNIPField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: _nipController,
        keyboardType: TextInputType.number,
        style: GoogleFonts.montserrat(
          color: const Color(0xFF2D3748),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: '12345678',
          hintStyle: GoogleFonts.montserrat(
            color: const Color(0xFF718096),
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.person_outline,
            color: Color(0xFF4A5FBF),
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'NIP tidak boleh kosong';
          }
          if (value.length < 8) {
            return 'NIP minimal 8 digit';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        style: GoogleFonts.montserrat(
          color: const Color(0xFF2D3748),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: GoogleFonts.montserrat(
            color: const Color(0xFF718096),
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xFF4A5FBF),
            size: 24,
          ),
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF718096),
              size: 24,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Password tidak boleh kosong';
          }
          if (value.length < 6) {
            return 'Password minimal 6 karakter';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52, // Ditingkatkan dari 48 ke 52
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A5FBF),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: const Color(0xFF4A5FBF).withOpacity(0.6),
          // Tambahkan padding untuk memastikan text tidak terpotong
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Login',
                style: GoogleFonts.montserrat(
                  fontSize: 16, // Dikurangi dari 18 ke 16
                  fontWeight: FontWeight.bold,
                  height: 1.2, // Tambahkan line height untuk kontrol yang lebih baik
                ),
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

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      debugPrint('LoginScreen: Attempting login with NIP: ${_nipController.text.trim()}');
      
      final success = await authProvider.login(
        _nipController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        if (success) {
          // Login berhasil
          debugPrint('LoginScreen: Login successful');
          
          // Tampilkan success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Login berhasil!',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Navigation akan ditangani oleh Consumer di app.dart
        } else {
          // Login gagal
          debugPrint('LoginScreen: Login failed');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Login gagal. Periksa NIP dan password Anda.',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFE83C3C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('LoginScreen: Login error: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Terjadi kesalahan. Silakan coba lagi.',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE83C3C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
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

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    
    path.lineTo(0, size.height * 0.15);
    
    // Create wave curve
    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.1);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.15);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    
    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.2);
    var secondEndPoint = Offset(size.width, size.height * 0.15);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    
    // Complete the path
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
