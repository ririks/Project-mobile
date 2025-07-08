import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../../providers.dart';
import '../screens.dart';

class RektorDashboard extends StatefulWidget {
  const RektorDashboard({super.key});

  @override
  State<RektorDashboard> createState() => _RektorDashboardState();
}

class _RektorDashboardState extends State<RektorDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final cutiProvider = Provider.of<CutiProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      dashboardProvider.loadDashboardData(
        authProvider.currentUser!.uuidUser,
        UserRole.rektor,
      );
      cutiProvider.loadPengajuanCuti(); // Load all pengajuan for rektor
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const RektorDashboardHome(),
      const RektorRiwayatScreen(),
      const RektorProfileScreen(),
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

class RektorDashboardHome extends StatefulWidget {
  const RektorDashboardHome({super.key});

  @override
  State<RektorDashboardHome> createState() => _RektorDashboardHomeState();
}

class _RektorDashboardHomeState extends State<RektorDashboardHome> {
  String _selectedFilter = 'Menunggu';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cutiProvider = Provider.of<CutiProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      cutiProvider.loadPengajuanCuti(); // Load all pengajuan for rektor
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
                  
                  // Statistik Singkat
                  _buildStatistikSingkat(),
                  
                  const SizedBox(height: 24),
                  
                  // Filter Status
                  _buildFilterStatus(),
                  
                  const SizedBox(height: 24),
                  
                  // Daftar Pengajuan
                  _buildDaftarPengajuan(),
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
                    final userName = auth.currentUser?.namaUser ?? "Rektor";
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
                  'Tinjau dan setujui pengajuan cuti pegawai',
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
                  color: Color(0xFFF5B500),
                  shape: BoxShape.circle,
                ),
                child: auth.currentUser?.profilStaf?.fotoProfil != null
                    ? ClipOval(
                        child: Image.network(
                          auth.currentUser!.profilStaf!.fotoProfil!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar(auth.currentUser?.namaUser ?? "User");
                          },
                        ),
                      )
                    : _buildDefaultAvatar(auth.currentUser?.namaUser ?? "User"),
              );
            },
          ),
        ],
      ),
    );
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
          name.isNotEmpty ? name[0].toUpperCase() : "R",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatistikSingkat() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Consumer<CutiProvider>(
        builder: (context, cutiProvider, _) {
          final menunggu = cutiProvider.pengajuanList.where((p) => p.statusPengajuan == 'Menunggu').length;
          final disetujui = cutiProvider.pengajuanList.where((p) => p.statusPengajuan == 'Disetujui').length;
          final ditolak = cutiProvider.pengajuanList.where((p) => p.statusPengajuan == 'Ditolak').length;
          
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pengajuan\nMasuk',
                  menunggu,
                  Icons.inbox_rounded,
                  const Color(0xFFF5B500),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Sudah\nDisetujui',
                  disetujui,
                  Icons.check_circle_rounded,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Ditolak',
                  ditolak,
                  Icons.cancel_rounded,
                  const Color(0xFFE83C3C),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          count.toString(),
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: const Color(0xFF718096),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterStatus() {
    return Consumer<CutiProvider>(
      builder: (context, cutiProvider, _) {
        final totalPengajuan = cutiProvider.pengajuanList.length;
        final menunggu = cutiProvider.pengajuanList.where((p) => p.statusPengajuan == 'Menunggu').length;
        final disetujui = cutiProvider.pengajuanList.where((p) => p.statusPengajuan == 'Disetujui').length;
        final ditolak = cutiProvider.pengajuanList.where((p) => p.statusPengajuan == 'Ditolak').length;
        
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterPill('Semua', totalPengajuan, const Color(0xFF9E9E9E)),
            _buildFilterPill('Menunggu', menunggu, const Color(0xFFF5B500)),
            _buildFilterPill('Disetujui', disetujui, const Color(0xFF4A5FBF)),
            _buildFilterPill('Ditolak', ditolak, const Color(0xFFE83C3C)),
          ],
        );
      },
    );
  }

  Widget _buildFilterPill(String label, int count, Color color) {
    final isSelected = _selectedFilter == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
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

  Widget _buildDaftarPengajuan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Pengajuan',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        Consumer<CutiProvider>(
          builder: (context, cutiProvider, _) {
            if (cutiProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Filter berdasarkan status yang dipilih
            List<dynamic> filteredPengajuan = cutiProvider.pengajuanList;
            
            if (_selectedFilter != 'Semua') {
              String statusFilter = _selectedFilter;
              filteredPengajuan = cutiProvider.pengajuanList
                  .where((p) => p.statusPengajuan == statusFilter)
                  .toList();
            }

            // Urutkan berdasarkan tanggal terbaru
            filteredPengajuan.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            
            if (filteredPengajuan.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Color(0xFF718096),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFilter == 'Semua' 
                            ? 'Belum ada pengajuan'
                            : 'Tidak ada pengajuan dengan status $_selectedFilter',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
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
              children: filteredPengajuan.map((pengajuan) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPengajuanCard(pengajuan),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPengajuanCard(pengajuan) {
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: InkWell(
        onTap: () {
          if (pengajuan.statusPengajuan == 'Menunggu') {
            _showPengajuanDetailModal(pengajuan);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan nama dan status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pengajuan.user?.namaUser ?? 'Unknown',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        pengajuan.user?.profilStaf?.jabatan ?? 'Staf',
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Jenis cuti dan tanggal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4A5FBF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                pengajuan.jenisCuti,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: const Color(0xFF4A5FBF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: const Color(0xFF718096),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateRange(pengajuan.tanggalMulai, pengajuan.tanggalSelesai),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: const Color(0xFF718096),
                  ),
                ),
                const Spacer(),
                Text(
                  '${pengajuan.jumlahHari} hari',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Alasan
            Text(
              pengajuan.alasan.length > 80 
                  ? '${pengajuan.alasan.substring(0, 80)}...'
                  : pengajuan.alasan,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: const Color(0xFF2D3748),
              ),
            ),
            
            // Tombol aksi untuk pengajuan menunggu
            if (pengajuan.statusPengajuan == 'Menunggu') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleApproval(pengajuan.uuidCuti, 'Disetujui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A5FBF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Setujui',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleApproval(pengajuan.uuidCuti, 'Ditolak'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFE83C3C),
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFE83C3C)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Tolak',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPengajuanDetailModal(pengajuan) {
    final TextEditingController komentarController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF4A5FBF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Detail Pengajuan Cuti',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Employee Info
                      _buildDetailSection('Informasi Pegawai', [
                        _buildDetailRow('Nama', pengajuan.user?.namaUser ?? 'Unknown'),
                        _buildDetailRow('NIP', pengajuan.user?.nip ?? 'Unknown'),
                        _buildDetailRow('Jabatan', pengajuan.user?.profilStaf?.jabatan ?? 'Staf'),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      // Leave Info
                      _buildDetailSection('Detail Cuti', [
                        _buildDetailRow('Jenis Cuti', pengajuan.jenisCuti),
                        _buildDetailRow('Tanggal', _formatDateRange(pengajuan.tanggalMulai, pengajuan.tanggalSelesai)),
                        _buildDetailRow('Jumlah Hari', '${pengajuan.jumlahHari} hari'),
                        _buildDetailRow('Alasan', pengajuan.alasan),
                      ]),
                      
                      const SizedBox(height: 16),
                      
                      // Comment Field
                      Text(
                        'Komentar (Opsional)',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: komentarController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Tambahkan komentar...',
                          hintStyle: GoogleFonts.montserrat(
                            color: const Color(0xFF718096),
                            fontSize: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF4A5FBF)),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFF0F0F0)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _handleApproval(pengajuan.uuidCuti, 'Disetujui', komentarController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A5FBF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Setujui',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _handleApproval(pengajuan.uuidCuti, 'Ditolak', komentarController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFE83C3C),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFE83C3C)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Tolak',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: const Color(0xFF718096),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: const Color(0xFF2D3748),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleApproval(String pengajuanId, String status, [String? komentar]) {
    final cutiProvider = Provider.of<CutiProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      cutiProvider.updateStatus(
        pengajuanId: pengajuanId,
        status: status,
        catatan: komentar?.isNotEmpty == true ? komentar : null,
        approvedBy: authProvider.currentUser!.uuidUser,
      ).then((success) {
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Pengajuan berhasil ${status.toLowerCase()}',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: status == 'Disetujui' ? const Color(0xFF10B981) : const Color(0xFFE83C3C),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal memproses pengajuan',
                style: GoogleFonts.montserrat(),
              ),
              backgroundColor: const Color(0xFFE83C3C),
            ),
          );
        }
      });
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    if (start.day == end.day && start.month == end.month && start.year == end.year) {
      return '${start.day} ${_getMonthName(start.month)} ${start.year}';
    }
    return '${start.day} ${_getMonthName(start.month)} - ${end.day} ${_getMonthName(end.month)} ${end.year}';
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month];
  }
}