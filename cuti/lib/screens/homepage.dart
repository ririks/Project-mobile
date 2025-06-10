import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ajukan_cuti.dart';
import 'riwayat_cuti.dart';
import 'profil.dart';

class HomePage extends StatefulWidget {
  final int idUser;

  const HomePage({super.key, required this.idUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      _HomePageContent(idUser: widget.idUser),
      AjukanCutiPage(idUser: widget.idUser),
      RiwayatCutiPage(idUser: widget.idUser), // Pastikan idUser diteruskan
      ProfilPage(idUser: widget.idUser),
    ];
  }

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
        selectedItemColor: const Color(0xFFFDD835),
        unselectedItemColor: const Color(0xFF757575),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ---

class _HomePageContent extends StatefulWidget {
  final int idUser;
  const _HomePageContent({required this.idUser});

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  final supabase = Supabase.instance.client;
  String _userName = "Pengguna"; 
  bool _isLoading = true;

  // Variabel untuk menyimpan hitungan status cuti
  int _pendingCount = 0;
  int _approvedCount = 0;
  int _rejectedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndNotifications();
  }

  Future<void> _loadUserDataAndNotifications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await supabase
          .from('karyawan')
          .select('nm_karyawan')
          .eq('id_karyawan', widget.idUser)
          .single();

      final allLeaves = await supabase
          .from('cuti')
          .select('id_cuti, status')
          .eq('id_karyawan', widget.idUser);

      // Inisialisasi ulang hitungan
      _pendingCount = 0;
      _approvedCount = 0;
      _rejectedCount = 0;

      // Hitung jumlah berdasarkan status
      for (var leave in allLeaves) {
        if (leave['status'] == 'Menunggu') {
          _pendingCount++;
        } else if (leave['status'] == 'Diterima') {
          _approvedCount++;
        } else if (leave['status'] == 'Ditolak') {
          _rejectedCount++;
        }
      }

      setState(() {
        _userName = user['nm_karyawan'] ?? "Pengguna";
        _isLoading = false;
      });

    } catch (e) {
      print('Gagal memuat data pengguna atau notifikasi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
      setState(() {
        _userName = "Pengguna";
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk membangun daftar notifikasi
  List<Widget> _buildNotificationList() {
    List<Widget> notifications = [];

    if (_pendingCount > 0) {
      notifications.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "• Anda memiliki $_pendingCount permohonan cuti yang tertunda.",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      );
    }
    if (_approvedCount > 0) {
      notifications.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "• Anda memiliki $_approvedCount permohan cuti yang sudah disetujui.",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      );
    }
    if (_rejectedCount > 0) { 
      notifications.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "• Anda memiliki $_rejectedCount permohonan cuti yang ditolak.",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      notifications.add(
        Text(
          "Tidak ada permohonan cuti baru atau tertunda saat ini.",
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      );
    }

    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFDD835)),
      );
    }

    String dynamicButtonText;
    if (_pendingCount > 0 || _approvedCount > 0 || _rejectedCount > 0) {
      dynamicButtonText = "Lihat Riwayat Cuti";
    } else {
      dynamicButtonText = "Ajukan Cuti Baru";
    }

    return Stack(
      children: [
        Positioned(
          top: -150,
          right: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.center,
                colors: [
                  const Color(0xFFFDD835).withOpacity(0.3),
                  const Color(0xFFFDD835).withOpacity(0.7),
                ],
                stops: const [0.0, 1.0],
                radius: 0.5,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: Alignment.center,
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.blue.withOpacity(0.3),
                ],
                stops: const [0.0, 1.0],
                radius: 0.5,
              ),
            ),
          ),
        ),
        ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat ${DateTime.now().hour < 12 ? 'Pagi' : DateTime.now().hour < 18 ? 'Siang' : 'Malam'},",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Panggil _buildNotificationCard dengan daftar notifikasi
                  _buildNotificationCard(
                      context, _buildNotificationList(), dynamicButtonText, widget.idUser),
                  const SizedBox(height: 30),
                  const Text(
                    "Akses Cepat",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    children: [
                      _buildQuickAccessCard(
                        context,
                        icon: Icons.add_box_outlined,
                        title: "Ajukan Cuti",
                        color: const Color(0xFFFDD835),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AjukanCutiPage(idUser: widget.idUser)),
                          );
                        },
                      ),
                      _buildQuickAccessCard(
                        context,
                        icon: Icons.history_outlined,
                        title: "Riwayat Cuti",
                        color: Colors.blue.shade300,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RiwayatCutiPage(idUser: widget.idUser)),
                          );
                        },
                      ),
                      _buildQuickAccessCard(
                        context,
                        icon: Icons.person_outline,
                        title: "Profil Saya",
                        color: Colors.green.shade300,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilPage(idUser: widget.idUser)),
                          );
                        },
                      ),
                      _buildQuickAccessCard(
                        context,
                        icon: Icons.assignment_turned_in,
                        title: "Absensi",
                        color: Colors.purple.shade300,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Fitur Absensi belum tersedia")),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationCard(BuildContext context, List<Widget> messages, String buttonText, int idUser) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_outlined, color: Color(0xFFE53935), size: 28),
                const SizedBox(width: 12),
                Text(
                  "Pemberitahuan Penting",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: messages, 
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RiwayatCutiPage(idUser: idUser)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDD835),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: color.withOpacity(0.8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}