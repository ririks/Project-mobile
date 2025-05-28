import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'login.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key}); 

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  static const Color primaryColor = Color(0xFFFDD835);
  static const Color darkGrey = Color(0xFF424242);

  static const String _registerTitle = 'Buat Akun Baru';
  static const String _registerSubtitle = 'Daftar sekarang dan mulailah cuti Anda.';
  static const String _nameLabel = 'Nama Lengkap';
  static const String _emailLabel = 'Email';
  static const String _passwordLabel = 'Kata Sandi';
  static const String _confirmPasswordLabel = 'Konfirmasi Kata Sandi';
  static const String _registerButtonText = 'Daftar';
  static const String _alreadyHaveAccountButtonText = 'Aku Udah Punya Akun';
  static const String _registrationFailedTitle = 'Pendaftaran Gagal';
  static const String _registrationSuccessTitle = 'Pendaftaran Berhasil';
  static const String _okButtonText = 'OK';
  static const String _allFieldsRequiredMessage = 'Semua kolom harus diisi!';
  static const String _passwordsDoNotMatchMessage = 'Kata Sandi tidak cocok!';
  static const String _registrationSuccessMessage = 'Pendaftaran berhasil!';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handles the registration logic.
  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _showErrorDialog(_allFieldsRequiredMessage);
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorDialog(_passwordsDoNotMatchMessage);
        return;
      }
      await Future.delayed(const Duration(seconds: 1)); 
      _showSuccessDialog(_registrationSuccessMessage);
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(_registrationFailedTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(_okButtonText),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(_registrationSuccessTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text(_okButtonText),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.8),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -screenHeight * 0.1, 
                    right: -screenWidth * 0.45, 
                    child: Container(
                      width: screenWidth * 1.2, 
                      height: screenHeight * 0.5, 
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment.center,
                          colors: [
                            primaryColor.withOpacity(0.5),
                            primaryColor.withOpacity(0.8),
                          ],
                          stops: const [0.4, 1.0],
                          radius: 0.3,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.05),
                        Image.asset(
                          'lib/assets/images/logos.png', 
                          width: screenWidth * 0.40,
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Text(
                          _registerSubtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Registration form container
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutCubic,
              top: keyboardHeight > 0 ? screenHeight * 0.15 : screenHeight * 0.25,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView( 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _registerTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: darkGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.06,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.025),

                        _buildTextField(
                          controller: _nameController,
                          labelText: _nameLabel,
                          icon: Icons.person_outline,
                          fontSize: 15,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama lengkap tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        _buildTextField(
                          controller: _emailController,
                          labelText: _emailLabel,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          fontSize: 15,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Masukkan email yang valid';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        _buildPasswordField(
                          controller: _passwordController,
                          labelText: _passwordLabel,
                          obscureText: _obscureTextPassword,
                          onPressedSuffix: () {
                            setState(() {
                              _obscureTextPassword = !_obscureTextPassword;
                            });
                          },
                          fontSize: 15,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kata sandi tidak boleh kosong';
                            }
                            if (value.length < 5) {
                              return 'Kata sandi minimal 5 karakter';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          labelText: _confirmPasswordLabel,
                          obscureText: _obscureTextConfirmPassword,
                          onPressedSuffix: () {
                            setState(() {
                              _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
                            });
                          },
                          fontSize: 15,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi kata sandi tidak boleh kosong';
                            }
                            if (value != _passwordController.text) {
                              return 'Kata sandi tidak cocok';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.035),

                        ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: darkGrey,
                            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            _registerButtonText,
                            style: TextStyle(
                              fontSize: screenWidth * 0.042,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                            side: const BorderSide(color: primaryColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                          child: Text(
                            _alreadyHaveAccountButtonText,
                            style: TextStyle(
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a customizable text input field.
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    double fontSize = 15,
    String? Function(String?)? validator, // Added validator
    List<TextInputFormatter>? inputFormatters, // Added inputFormatters
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: false, // Ensure it's not obscured by default
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: darkGrey.withOpacity(0.7), fontSize: fontSize),
        prefixIcon: icon != null
            ? Icon(icon, color: primaryColor.withOpacity(0.7))
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        fillColor: Colors.grey.shade50,
        filled: true,
      ),
      style: TextStyle(color: darkGrey, fontSize: fontSize),
    );
  }

  /// Builds a customizable password input field.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onPressedSuffix,
    double fontSize = 15,
    String? Function(String?)? validator, // Added validator
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: darkGrey.withOpacity(0.7), fontSize: fontSize),
        prefixIcon: Icon(Icons.lock_outline, color: primaryColor.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(12.0),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: darkGrey.withOpacity(0.7),
          ),
          onPressed: onPressedSuffix,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        fillColor: Colors.grey.shade50,
        filled: true,
      ),
      style: TextStyle(color: darkGrey, fontSize: fontSize),
    );
  }
}