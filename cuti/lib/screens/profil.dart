import 'package:flutter/material.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with SingleTickerProviderStateMixin {
  final TextEditingController _fullNameController = TextEditingController(text: 'Nama Lengkap Pengguna');
  final TextEditingController _emailController = TextEditingController(text: 'pengguna.email@example.com');
  final TextEditingController _passwordController = TextEditingController(text: '********'); 
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isEditingFullName = false;
  bool _isEditingEmail = false;
  bool _isEditingPassword = false;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            "Konfirmasi Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          content: const Text(
            "Apakah Anda yakin ingin keluar dari akun?",
            style: TextStyle(color: Color(0xFF757575)),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Batal",
                style: TextStyle(color: Color(0xFF757575)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anda telah berhasil logout!'),
                    backgroundColor: Color(0xFFFDD835),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                print('User logged out!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _toggleEdit(String fieldName) {
    setState(() {
      if (fieldName == 'fullName') {
        _isEditingFullName = !_isEditingFullName;
        if (_isEditingFullName) {
          _fullNameFocusNode.requestFocus();
        } else {
          _fullNameFocusNode.unfocus(); 
          print('Full Name updated to: ${_fullNameController.text}');
        }
      } else if (fieldName == 'email') {
        _isEditingEmail = !_isEditingEmail;
        if (_isEditingEmail) {
          _emailFocusNode.requestFocus();
        } else {
          _emailFocusNode.unfocus();
          print('Email updated to: ${_emailController.text}');
        }
      } else if (fieldName == 'password') {
        _isEditingPassword = !_isEditingPassword;
        if (_isEditingPassword) {
          _passwordFocusNode.requestFocus();
        } else {
          _passwordFocusNode.unfocus();
          print('Password updated to: ${_passwordController.text}');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFFDD835),
                backgroundImage: NetworkImage(
                  'https://placehold.co/120x120/FDD835/424242?text=PP',
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'Nama Lengkap Pengguna',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              'Status: Aktif',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildEditableInfoField(
              controller: _fullNameController,
              label: 'Nama Lengkap',
              icon: Icons.person_outline,
              isEditing: _isEditingFullName,
              focusNode: _fullNameFocusNode,
              onEditTap: () => _toggleEdit('fullName'),
            ),
            const SizedBox(height: 20),
            _buildEditableInfoField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              isEditing: _isEditingEmail,
              focusNode: _emailFocusNode,
              onEditTap: () => _toggleEdit('email'),
            ),
            const SizedBox(height: 20),
            _buildEditableInfoField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: !_isEditingPassword,
              isEditing: _isEditingPassword,
              focusNode: _passwordFocusNode,
              onEditTap: () => _toggleEdit('password'),
            ),
            const SizedBox(height: 40),
            ScaleTransition(
              scale: _buttonScaleAnimation,
              child: Center(
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Logout',
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
    );
  }

  Widget _buildEditableInfoField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool obscureText = false,
    required bool isEditing,
    required FocusNode focusNode,
    required VoidCallback onEditTap,
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
          readOnly: !isEditing,
          obscureText: obscureText,
          focusNode: focusNode,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: const Color(0xFFFDD835)) : null,
            suffixIcon: IconButton(
              icon: Icon(
                isEditing ? Icons.check : Icons.edit, 
                color: const Color(0xFFFDD835),
              ),
              onPressed: onEditTap, 
            ),
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
        ),
      ],
    );
  }
}