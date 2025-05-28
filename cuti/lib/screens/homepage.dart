import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import 'ajukan_cuti.dart'; 
import 'riwayat_cuti.dart'; 
import 'profil.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; 

  static final List<Widget> _widgetOptions = <Widget>[
    _HomePageContent(), 
    const AjukanCutiPage(), 
    const RiwayatCutiPage(), 
    const ProfilPage(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex), 
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Ajukan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            Colors.red, 
        unselectedItemColor:
            const Color(0xFF757575), 
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, 
        backgroundColor:
            Colors.white, 
        selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold), 
      ),
    );
  }
}

// New widget for the custom homepage content
class _HomePageContent extends StatelessWidget {
  const _HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    String userName = "User"; 
    int sisaCutiTahunan = 12; 
    int sisaCutiKhusus = 3; 
    return Stack(
      children: [
        Positioned(
          top: -90,
          right: -180,
          child: Container(
            width: 500,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.center,
                colors: [
                  const Color(0xFFFDD835).withOpacity(0.5), // Lighter yellow
                  const Color(0xFFFDD835), // Original yellow
                ],
                stops: const [0.4, 1.0],
                radius: 0.3,
              ),
            ),
          ),
        ),
        ListView(
          padding: EdgeInsets.zero, 
          children: [
            const SizedBox(height: 40), 
            Padding(
              padding:
                  const EdgeInsets.all(24.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, $userName!",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242), 
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Selamat datang di Aplikasi Cuti Anda.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF616161), 
                    ),
                  ),
                ],
              ),
            ),
            _buildLeaveSummaryCard(
                sisaCutiTahunan, sisaCutiKhusus, context), 
            const SizedBox(height: 24), 

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Informasi Cuti Penting",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF424242),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: "Cuti Tahunan Anda akan hangus dalam 3 bulan.",
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.notifications_active_outlined,
                        text: "Anda memiliki 1 permohonan cuti yang tertunda.",
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        icon: Icons.check_circle_outline,
                        text: "Cuti Anda yang terakhir disetujui: 2 hari pada 15 Mei 2025.",
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40), 
          ],
        ),
      ],
    );
  }

  Widget _buildLeaveSummaryCard(
      int sisaCutiTahunan, int sisaCutiKhusus, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFDD835).withOpacity(0.8), 
            const Color(0xFFFDD835), 
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ringkasan Cuti Anda",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.beach_access_outlined,
                    color: Color(0xFF424242), size: 30),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sisa Cuti Tahunan:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF424242),
                      ),
                    ),
                    Text(
                      "$sisaCutiTahunan hari",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF424242),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.medical_services_outlined,
                    color: Color(0xFF424242), size: 30),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sisa Cuti Khusus:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF424242),
                      ),
                    ),
                    Text(
                      "$sisaCutiKhusus hari",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF424242),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AjukanCutiPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935), 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Ajukan Cuti Baru",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF616161),
            ),
          ),
        ),
      ],
    );
  }
}