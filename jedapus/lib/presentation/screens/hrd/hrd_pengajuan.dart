import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers.dart';

class HRDPengajuanScreen extends StatefulWidget {
  const HRDPengajuanScreen({super.key});

  @override
  State<HRDPengajuanScreen> createState() => _HRDPengajuanScreenState();
}

class _HRDPengajuanScreenState extends State<HRDPengajuanScreen> {
  String _selectedFilter = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPengajuan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPengajuan() {
    final cutiProvider = Provider.of<CutiProvider>(context, listen: false);
    cutiProvider.loadPengajuanCuti(); // Load all pengajuan for HRD
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadPengajuan();
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
                
                // Search dan Filter
                _buildSearchAndFilter(),
                
                const SizedBox(height: 24),
                
                // Pengajuan List
                _buildPengajuanList(),
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
            'Kelola Pengajuan',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review dan kelola semua pengajuan cuti',
            style: GoogleFonts.montserrat(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E5E5)),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama pegawai...',
              hintStyle: GoogleFonts.montserrat(
                color: const Color(0xFF718096),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF718096),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: const Color(0xFF2D3748),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Filter Pills
        Consumer<CutiProvider>(
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
        ),
      ],
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

  Widget _buildPengajuanList() {
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

        // Filter berdasarkan search
        if (_searchController.text.isNotEmpty) {
          filteredPengajuan = filteredPengajuan
              .where((p) => p.user?.namaUser
                  ?.toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ?? false)
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
                    Icons.search_off_rounded,
                    size: 64,
                    color: Color(0xFF718096),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isNotEmpty
                        ? 'Tidak ditemukan pengajuan dengan kata kunci "${_searchController.text}"'
                        : _selectedFilter == 'Semua' 
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header hasil
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Ditemukan ${filteredPengajuan.length} pengajuan',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: const Color(0xFF718096),
                ),
              ),
            ),
            
            // List pengajuan
            ...filteredPengajuan.map((pengajuan) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildPengajuanCard(pengajuan),
              );
            }),
          ],
        );
      },
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
                      '${pengajuan.user?.profilStaf?.jabatan ?? 'Staf'} • ${pengajuan.user?.nip ?? '-'}',
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
          Row(
            children: [
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
          
          // Catatan jika ada
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
    );
  }

  void _handleApproval(String pengajuanId, String status) {
    final cutiProvider = Provider.of<CutiProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      cutiProvider.updateStatus(
        pengajuanId: pengajuanId,
        status: status,
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