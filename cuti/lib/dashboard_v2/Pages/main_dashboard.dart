import 'package:flutter/material.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 80, color: Colors.orange),
          SizedBox(height: 20),
          Text('Selamat Datang di Dashboard Admin!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Gunakan menu di samping untuk mengelola aplikasi.', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
