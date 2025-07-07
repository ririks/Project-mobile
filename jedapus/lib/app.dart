import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'presentation/screens/screens.dart';
import 'presentation/providers.dart';

class JedapusApp extends StatefulWidget {
  const JedapusApp({super.key});

  @override
  State<JedapusApp> createState() => _JedapusAppState();
}

class _JedapusAppState extends State<JedapusApp> {
  @override
  void initState() {
    super.initState();
    // Pastikan auth provider sudah diinisialisasi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jedapus - Aplikasi Cuti Pegawai',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1A45A0),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.montserratTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A45A0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (kDebugMode) {
            debugPrint('JedapusApp: Building with auth state:');
            debugPrint('  - isLoading: ${auth.isLoading}');
            debugPrint('  - isAuthenticated: ${auth.isAuthenticated}');
            debugPrint('  - currentUser: ${auth.currentUser?.namaUser}');
            debugPrint('  - userRole: ${auth.currentUser?.role}');
          }

          // Tampilkan splash screen saat loading
          if (auth.isLoading) {
            return const SplashScreen();
          }
          
          // Jika tidak authenticated atau tidak ada user, ke login
          if (!auth.isAuthenticated || auth.currentUser == null) {
            return const LoginScreen();
          }
          
          // Navigate berdasarkan role
          final userRole = auth.currentUser!.role;
          
          switch (userRole) {
            case UserRole.hrd:
              return const HRDDashboard();
            case UserRole.rektor:
              return const RektorDashboard();
            case UserRole.staf:
              return const StafDashboard();
          }
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A45A0), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                'JEDAPUS',
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Aplikasi Pengajuan dan Pencatatan Cuti Pegawai',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}