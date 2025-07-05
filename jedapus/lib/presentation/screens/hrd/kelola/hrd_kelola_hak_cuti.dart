import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models.dart' as models;
import '../../../providers.dart';

class HRDKelolaHakCutiScreen extends StatefulWidget {
  const HRDKelolaHakCutiScreen({super.key});

  @override
  State<HRDKelolaHakCutiScreen> createState() => _HRDKelolaHakCutiScreenState();
}

class _HRDKelolaHakCutiScreenState extends State<HRDKelolaHakCutiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedJenisCuti = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadEmployees() {
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
    employeeProvider.loadEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5FBF),
        foregroundColor: Colors.white,
        title: Text(
          'Kelola Hak Cuti',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showBulkUpdateModal(),
            icon: const Icon(Icons.edit_note),
            tooltip: 'Update Massal',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Search dan Filter
              _buildSearchAndFilter(),
              
              const SizedBox(height: 24),
              
              // Info Card
              _buildInfoCard(),
              
              const SizedBox(height: 24),
              
              // List Pegawai
              Expanded(
                child: _buildEmployeeList(),
              ),
            ],
          ),
        ),
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
        
        // Jenis Cuti Filter
        Wrap(
          spacing: 8,
          children: ['Semua', 'Cuti Tahunan', 'Cuti Sakit', 'Cuti Lainnya'].map((jenis) {
            final isSelected = _selectedJenisCuti == jenis;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedJenisCuti = jenis;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4A5FBF) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4A5FBF) : const Color(0xFFE5E5E5),
                  ),
                ),
                child: Text(
                  jenis,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF4A5FBF),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5FBF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A5FBF).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFF4A5FBF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Kelola kuota cuti pegawai untuk tahun ${DateTime.now().year}. Klik pada pegawai untuk mengedit hak cuti.',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: const Color(0xFF4A5FBF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList() {
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, _) {
        if (employeeProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final filteredEmployees = employeeProvider.getFilteredEmployees(
          searchQuery: _searchController.text,
        );

        if (filteredEmployees.isEmpty) {
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
                        ? 'Tidak ditemukan pegawai dengan kata kunci "${_searchController.text}"'
                        : 'Belum ada data pegawai',
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

        return ListView.builder(
          itemCount: filteredEmployees.length,
          itemBuilder: (context, index) {
            final employee = filteredEmployees[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildEmployeeCard(employee),
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeeCard(models.User employee) {
    final hakCutiData = [
      {'jenis': 'Cuti Tahunan', 'sisa': 8, 'total': 24, 'color': const Color(0xFF4A5FBF)},
      {'jenis': 'Cuti Sakit', 'sisa': 6, 'total': 12, 'color': const Color(0xFFE83C3C)},
      {'jenis': 'Cuti Lainnya', 'sisa': 17, 'total': 18, 'color': const Color(0xFF9E9E9E)},
    ];

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
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5B500),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    employee.namaUser.isNotEmpty ? employee.namaUser[0] : 'U',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.namaUser,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      'NIP: ${employee.nip} • ${employee.profilStaf?.jabatan ?? 'Staf'}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              
              IconButton(
                onPressed: () => _showEditHakCutiModal(employee, hakCutiData),
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFF4A5FBF),
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF4A5FBF).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Hak Cuti Cards
          if (_selectedJenisCuti == 'Semua') ...[
            ...hakCutiData.map((data) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildHakCutiRow(
                data['jenis'] as String,
                data['sisa'] as int,
                data['total'] as int,
                data['color'] as Color,
              ),
            )),
          ] else ...[
            ...hakCutiData.where((data) => data['jenis'] == _selectedJenisCuti).map((data) => 
              _buildHakCutiRow(
                data['jenis'] as String,
                data['sisa'] as int,
                data['total'] as int,
                data['color'] as Color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHakCutiRow(String jenis, int sisa, int total, Color color) {
    final percentage = total > 0 ? (sisa / total) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jenis,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sisa: $sisa dari $total hari',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 4,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color.withValues(alpha: 0.2)),
                ),
                CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Center(
                  child: Text(
                    sisa.toString(),
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditHakCutiModal(models.User employee, List<Map<String, dynamic>> hakCutiData) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                        'Edit Hak Cuti - ${employee.namaUser}',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
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
                    children: hakCutiData.map((data) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildEditHakCutiRow(
                          data['jenis'] as String,
                          data['sisa'] as int,
                          data['total'] as int,
                          data['color'] as Color,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              // Actions
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
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF718096),
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFE5E5E5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Batal',
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
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Hak cuti berhasil diupdate',
                                style: GoogleFonts.montserrat(),
                              ),
                              backgroundColor: const Color(0xFF4A5FBF),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A5FBF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Simpan',
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

  Widget _buildEditHakCutiRow(String jenis, int sisa, int total, Color color) {
    final sisaController = TextEditingController(text: sisa.toString());
    final totalController = TextEditingController(text: total.toString());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jenis,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Cuti',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: totalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Total',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: color),
                        ),
                        contentPadding: const EdgeInsets.all(8),
                        isDense: true,
                      ),
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sisa Cuti',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: sisaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Sisa',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: color),
                        ),
                        contentPadding: const EdgeInsets.all(8),
                        isDense: true,
                      ),
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
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

  void _showBulkUpdateModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 400),
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
                        'Update Massal Hak Cuti',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reset semua hak cuti pegawai untuk tahun ${DateTime.now().year}',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFE69C)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFF856404),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tindakan ini akan mereset semua hak cuti ke nilai default.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: const Color(0xFF856404),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Nilai Default:',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Cuti Tahunan: 24 hari\n• Cuti Sakit: 12 hari\n• Cuti Lainnya: 18 hari',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: const Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Actions
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
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF718096),
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFE5E5E5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Batal',
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
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Hak cuti semua pegawai berhasil direset',
                                style: GoogleFonts.montserrat(),
                              ),
                              backgroundColor: const Color(0xFF4A5FBF),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5B500),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Reset Semua',
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
}