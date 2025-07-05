import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../../providers.dart';

class StafRiwayatScreen extends StatefulWidget {
  const StafRiwayatScreen({super.key});

  @override
  State<StafRiwayatScreen> createState() => _StafRiwayatScreenState();
}

class _StafRiwayatScreenState extends State<StafRiwayatScreen> {
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  void _loadRiwayat() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cutiProvider = Provider.of<CutiProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      cutiProvider.loadPengajuanCuti(userId: authProvider.currentUser!.uuidUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadRiwayat();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: 24),
                
                // Filter Pills
                _buildFilterSection(),
                
                const SizedBox(height: 24),
                
                // Riwayat List
                _buildRiwayatList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Cuti',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat semua pengajuan cuti Anda',
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
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

  Widget _buildRiwayatList() {
    return Consumer<CutiProvider>(
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
                    Icons.history_outlined,
                    size: 64,
                    color: Color(0xFF718096),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedFilter == 'Semua' 
                        ? 'Belum ada riwayat pengajuan'
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
              child: _buildRiwayatCard(pengajuan),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildRiwayatCard(pengajuan) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card dengan status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  pengajuan.jenisCuti,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
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
          
          // Tanggal
          Row(
            children: [
              Icon(
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
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Durasi
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: const Color(0xFF718096),
              ),
              const SizedBox(width: 8),
              Text(
                '${pengajuan.jumlahHari} hari',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Alasan
          Text(
            'Alasan:',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pengajuan.alasan,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: const Color(0xFF2D3748),
            ),
          ),
          
          // Catatan rektor jika ada
          if (pengajuan.catatanRektor != null && pengajuan.catatanRektor!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan:',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pengajuan.catatanRektor!,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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