import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../../core/constants.dart';
import '../../providers.dart';
import '../screens.dart';

class StafDashboard extends StatefulWidget {
  const StafDashboard({super.key});

  @override
  State<StafDashboard> createState() => _StafDashboardState();
}

class _StafDashboardState extends State<StafDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dashboardProvider =
        Provider.of<DashboardProvider>(context, listen: false);
    final cutiProvider = Provider.of<CutiProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      dashboardProvider.loadDashboardData(
        authProvider.currentUser!.uuidUser,
        UserRole.staf,
      );
      cutiProvider.loadPengajuanCuti(
          userId: authProvider.currentUser!.uuidUser);
    }
  }

  // Method untuk mengubah tab dari child widget
  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      StafDashboardHome(onNavigateToTab: _changeTab), // Pass callback
      const StafPengajuanScreen(),
      const StafRiwayatScreen(),
      const StafProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: const Color(0xFF1A45A0),
          unselectedItemColor: const Color(0xFF9E9E9E),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Pengajuan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class StafDashboardHome extends StatefulWidget {
  final Function(int)? onNavigateToTab; // Tambahkan callback parameter
  
  const StafDashboardHome({super.key, this.onNavigateToTab});

  @override
  State<StafDashboardHome> createState() => _StafDashboardHomeState();
}

class _StafDashboardHomeState extends State<StafDashboardHome> {
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    // Force load data saat widget init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cutiProvider = Provider.of<CutiProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      debugPrint(
          'Loading data for user: ${authProvider.currentUser!.uuidUser}');
      cutiProvider.loadPengajuanCuti(
          userId: authProvider.currentUser!.uuidUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeaderSection(),

                  const SizedBox(height: 24),

                  // Cuti Summary Cards
                  _buildCutiSummaryCards(),

                  const SizedBox(height: 24),

                  // Pengajuan Status Summary
                  _buildPengajuanStatusSummary(),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(context),

                  const SizedBox(height: 24),

                  // Notifikasi Section
                  _buildNotifikasiSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A5FBF), Color(0xFF5B6BC7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final userName = auth.currentUser?.namaUser ?? "User";
                    final words = userName.split(' ');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${words.first}',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (words.length > 1) ...[
                          Text(
                            words.skip(1).join(' '),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  'Apa kabar? Mari kelola cutimu.',
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: _buildProfileImage(auth),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(AuthProvider auth) {
    final fotoProfil = auth.currentUser?.profilStaf?.fotoProfil;
    
    // Jika ada foto profil dan valid Base64
    if (fotoProfil != null && fotoProfil.isNotEmpty && _isValidBase64(fotoProfil)) {
      try {
        return Image.memory(
          base64Decode(fotoProfil),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar(auth.currentUser?.namaUser ?? "User");
          },
        );
      } catch (e) {
        debugPrint('Error decoding profile image: $e');
        return _buildDefaultAvatar(auth.currentUser?.namaUser ?? "User");
      }
    }
    
    // Fallback ke avatar default
    return _buildDefaultAvatar(auth.currentUser?.namaUser ?? "User");
  }

  bool _isValidBase64(String str) {
    try {
      if (str.length % 4 != 0) {
        return false;
      }
      
      final base64RegExp = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      if (!base64RegExp.hasMatch(str)) {
        return false;
      }
      
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFF5B500),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : "U",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCutiSummaryCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Consumer<DashboardProvider>(
        builder: (context, dashboard, _) {
          if (dashboard.isLoading) {
            return Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildLoadingCard(),
                ),
              ),
            );
          }

          final hakCuti = dashboard.stats?.hakCuti ?? [];

          final cutiTahunan =
              hakCuti.where((h) => h.jenisCuti == 'Cuti Tahunan').firstOrNull;
          final cutiSakit =
              hakCuti.where((h) => h.jenisCuti == 'Cuti Sakit').firstOrNull;
          final cutiLainnya =
              hakCuti.where((h) => h.jenisCuti == 'Cuti Lainnya').firstOrNull;

          return Column(
            children: [
              _buildCutiCard(
                'Sisa Cuti Tahunan',
                cutiTahunan?.sisaCuti ?? 8,
                cutiTahunan?.totalCuti ?? 24,
                const Color(0xFF4A5FBF),
              ),
              const SizedBox(height: 16),
              _buildCutiCard(
                'Sisa Cuti Sakit',
                cutiSakit?.sisaCuti ?? 6,
                cutiSakit?.totalCuti ?? 12,
                const Color(0xFFE83C3C),
              ),
              const SizedBox(height: 16),
              _buildCutiCard(
                'Sisa Cuti Lainnya',
                cutiLainnya?.sisaCuti ?? 17,
                cutiLainnya?.totalCuti ?? 18,
                const Color(0xFF9E9E9E),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCutiCard(String title, int current, int total, Color color) {
    final progress = total > 0 ? current / total : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 6,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      color.withValues(alpha: 0.1)),
                ),
              ),
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child: Text(
                  current.toString(),
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total cuti: $total',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPengajuanStatusSummary() {
    return Consumer<CutiProvider>(
      builder: (context, cutiProvider, _) {
        // Hitung statistik dari data yang ada
        final totalPengajuan = cutiProvider.pengajuanList.length;
        final menunggu = cutiProvider.pengajuanList
            .where((p) => p.statusPengajuan == 'Menunggu')
            .length;
        final disetujui = cutiProvider.pengajuanList
            .where((p) => p.statusPengajuan == 'Disetujui')
            .length;
        final ditolak = cutiProvider.pengajuanList
            .where((p) => p.statusPengajuan == 'Ditolak')
            .length;

        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildStatusPill(
              'Total Pengajuan',
              totalPengajuan,
              const Color(0xFF9E9E9E),
              false,
            ),
            _buildStatusPill(
              'Menunggu',
              menunggu,
              const Color(0xFFF5B500),
              true,
            ),
            _buildStatusPill(
              'Disetujui',
              disetujui,
              const Color(0xFF4A5FBF),
              true,
            ),
            _buildStatusPill(
              'Ditolak',
              ditolak,
              const Color(0xFFE83C3C),
              true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusPill(String label, int count, Color color, bool isFilter) {
    final isSelected = isFilter && _selectedFilter == label;

    return GestureDetector(
      onTap: isFilter
          ? () {
              setState(() {
                _selectedFilter = isSelected ? 'Semua' : label;
              });
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Ajukan Cuti',
                Icons.add_rounded,
                const Color(0xFF4A5FBF),
                Colors.white,
                () {
                  // Navigate ke tab Pengajuan (index 1)
                  widget.onNavigateToTab?.call(1);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Lihat Riwayat',
                Icons.history_rounded,
                Colors.white,
                const Color(0xFF4A5FBF),
                () {
                  // Navigate ke tab Riwayat (index 2)
                  widget.onNavigateToTab?.call(2);
                },
                hasBorder: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed, {
    bool hasBorder = false,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: textColor),
        label: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: hasBorder ? 0 : 2,
          shadowColor: backgroundColor == Colors.white
              ? Colors.transparent
              : backgroundColor.withValues(alpha: 0.3),
          side: hasBorder ? BorderSide(color: textColor, width: 1.5) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildNotifikasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifikasi',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Consumer<CutiProvider>(
          builder: (context, cutiProvider, _) {
            debugPrint('CutiProvider state:');
            debugPrint('- isLoading: ${cutiProvider.isLoading}');
            debugPrint(
                '- pengajuanList length: ${cutiProvider.pengajuanList.length}');
            debugPrint('- error: ${cutiProvider.error}');

            if (cutiProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (cutiProvider.error != null) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Error: ${cutiProvider.error}',
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFFE83C3C),
                    fontSize: 14,
                  ),
                ),
              );
            }

            // Filter berdasarkan status yang dipilih
            List<dynamic> filteredPengajuan = cutiProvider.pengajuanList;

            if (_selectedFilter != 'Semua' && _selectedFilter != 'Total') {
              String statusFilter = _selectedFilter;
              filteredPengajuan = cutiProvider.pengajuanList
                  .where((p) => p.statusPengajuan == statusFilter)
                  .toList();
            }

            // Urutkan berdasarkan tanggal terbaru (created_at descending)
            filteredPengajuan
                .sort((a, b) => b.createdAt.compareTo(a.createdAt));

            // Ambil maksimal 5 terbaru untuk notifikasi
            final recentPengajuan = filteredPengajuan.take(5).toList();

            if (recentPengajuan.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.history_outlined,
                        size: 48,
                        color: Color(0xFF718096),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFilter == 'Semua'
                            ? 'Belum ada riwayat pengajuan'
                            : 'Tidak ada pengajuan dengan status $_selectedFilter',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xFF718096),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Tampilkan maksimal 5 riwayat pengajuan
                ...recentPengajuan.map((pengajuan) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildNotificationCard(pengajuan),
                  );
                }).toList(),

                // Tampilkan info jika ada lebih dari 5 pengajuan
                if (filteredPengajuan.length > 5) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '+ ${filteredPengajuan.length - 5} pengajuan lainnya',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationCard(pengajuan) {
    Color statusColor;
    switch (pengajuan.statusPengajuan.toLowerCase()) {
      case 'disetujui':
        statusColor = const Color(0xFF4A5FBF);
        break;
      case 'ditolak':
        statusColor = const Color(0xFFE83C3C);
        break;
      default:
        statusColor = const Color(0xFFF5B500);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF5B500),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'U',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pengajuan.alasan.length > 35
                      ? '${pengajuan.alasan.substring(0, 35)}...'
                      : pengajuan.alasan,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pengajuan.jenisCuti,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
                Text(
                  _formatDateRange(
                      pengajuan.tanggalMulai, pengajuan.tanggalSelesai),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pengajuan.statusPengajuan,
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    if (start.day == end.day &&
        start.month == end.month &&
        start.year == end.year) {
      return '${start.day} ${_getMonthName(start.month)} ${start.year}';
    }
    return '${start.day} ${_getMonthName(start.month)} - ${end.day} ${_getMonthName(end.month)} ${end.year}';
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month];
  }
}
