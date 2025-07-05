import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers.dart';

class HRDLaporanScreen extends StatefulWidget {
  const HRDLaporanScreen({super.key});

  @override
  State<HRDLaporanScreen> createState() => _HRDLaporanScreenState();
}

class _HRDLaporanScreenState extends State<HRDLaporanScreen> {
  String _selectedPeriod = 'Bulan Ini';
  String _selectedJenisCuti = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadLaporan();
  }

  void _loadLaporan() {
    final cutiProvider = Provider.of<CutiProvider>(context, listen: false);
    cutiProvider.loadPengajuanCuti(); // Load all data for reports
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadLaporan();
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
                
                // Filter Section
                _buildFilterSection(),
                
                const SizedBox(height: 24),
                
                // Statistik Umum
                _buildStatistikUmum(),
                
                const SizedBox(height: 24),
                
                // Chart Placeholder
                _buildChartSection(),
                
                const SizedBox(height: 24),
                
                // Laporan Detail
                _buildLaporanDetail(),
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
            'Laporan Cuti',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analisis dan statistik pengajuan cuti',
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Laporan',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Period Filter
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Periode',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          isExpanded: true,
                          items: ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Tahun Ini']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedPeriod = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Jenis Cuti Filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jenis Cuti',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedJenisCuti,
                          isExpanded: true,
                          items: ['Semua', 'Cuti Tahunan', 'Cuti Sakit', 'Cuti Lainnya']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: const Color(0xFF2D3748),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedJenisCuti = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikUmum() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
    ),
    child: Consumer<CutiProvider>(
      builder: (context, cutiProvider, _) {
        final totalPengajuan = cutiProvider.pengajuanList.length;
        final disetujui = cutiProvider.pengajuanList.where((p) => p.statusPengajuan == 'Disetujui').length; // TAMBAHKAN ini
        final menunggu = cutiProvider.pengajuanList.where((p) => p.statusPengajuan == 'Menunggu').length;
        
        // Hitung total hari cuti yang disetujui
        final totalHariCuti = cutiProvider.pengajuanList
            .where((p) => p.statusPengajuan == 'Disetujui')
            .fold(0, (sum, p) => sum + (p.jumlahHari));
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik Umum',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Row 1
            Row(
              children: [
                Expanded(
                  child: _buildStatisticCard(
                    'Total Pengajuan',
                    totalPengajuan.toString(),
                    Icons.assignment_rounded,
                    const Color(0xFF4A5FBF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatisticCard(
                    'Total Hari Cuti',
                    '$totalHariCuti hari',
                    Icons.calendar_month_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Row 2
            Row(
              children: [
                Expanded(
                  child: _buildStatisticCard(
                    'Tingkat Persetujuan',
                    totalPengajuan > 0 ? '${((disetujui / totalPengajuan) * 100).toStringAsFixed(1)}%' : '0%', // Line 304 - sekarang 'disetujui' sudah didefinisikan
                    Icons.trending_up_rounded,
                    const Color(0xFFF5B500),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatisticCard(
                    'Menunggu Review',
                    menunggu.toString(),
                    Icons.schedule_rounded,
                    const Color(0xFFE83C3C),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

  Widget _buildStatisticCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grafik Pengajuan Cuti',
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Chart placeholder
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  size: 48,
                  color: const Color(0xFF718096),
                ),
                const SizedBox(height: 12),
                Text(
                  'Grafik akan ditampilkan di sini',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: const Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Implementasi chart library diperlukan',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildLaporanDetail() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detail Laporan',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Export functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Fitur export akan segera tersedia',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: const Color(0xFF4A5FBF),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 16),
                label: Text(
                  'Export',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5FBF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Consumer<CutiProvider>(
            builder: (context, cutiProvider, _) {
              if (cutiProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Group pengajuan by jenis cuti
              final pengajuanByJenis = <String, List<dynamic>>{};
              for (final pengajuan in cutiProvider.pengajuanList) {
                if (!pengajuanByJenis.containsKey(pengajuan.jenisCuti)) {
                  pengajuanByJenis[pengajuan.jenisCuti] = [];
                }
                pengajuanByJenis[pengajuan.jenisCuti]!.add(pengajuan);
              }

              if (pengajuanByJenis.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Tidak ada data untuk ditampilkan',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: pengajuanByJenis.entries.map((entry) {
                  final jenisCuti = entry.key;
                  final pengajuanList = entry.value;
                  final totalPengajuan = pengajuanList.length;
                  final disetujui = pengajuanList.where((p) => p.statusPengajuan == 'Disetujui').length;
                  final totalHari = pengajuanList
                      .where((p) => p.statusPengajuan == 'Disetujui')
                      .fold(0, (sum, p) => sum + (p.jumlahHari as int));

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildJenisCutiCard(jenisCuti, totalPengajuan, disetujui, totalHari),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildJenisCutiCard(String jenisCuti, int totalPengajuan, int disetujui, int totalHari) {
    Color color;
    switch (jenisCuti) {
      case 'Cuti Tahunan':
        color = const Color(0xFF4A5FBF);
        break;
      case 'Cuti Sakit':
        color = const Color(0xFFE83C3C);
        break;
      default:
        color = const Color(0xFF9E9E9E);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                jenisCuti,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$totalPengajuan pengajuan',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disetujui',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    Text(
                      '$disetujui pengajuan',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Hari',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    Text(
                      '$totalHari hari',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Persentase',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    Text(
                      totalPengajuan > 0 ? '${((disetujui / totalPengajuan) * 100).toStringAsFixed(1)}%' : '0%',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}