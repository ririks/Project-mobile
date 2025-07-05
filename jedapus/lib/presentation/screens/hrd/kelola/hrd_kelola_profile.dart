import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models.dart' as models;
import '../../../providers.dart';

class HRDKelolaProfileScreen extends StatefulWidget {
  const HRDKelolaProfileScreen({super.key});

  @override
  State<HRDKelolaProfileScreen> createState() => _HRDKelolaProfileScreenState();
}

class _HRDKelolaProfileScreenState extends State<HRDKelolaProfileScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedJabatan = 'Semua';

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
          'Kelola Profil Pegawai',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showTambahProfilModal(),
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Profil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahProfilModal(),
        backgroundColor: const Color(0xFF4A5FBF),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Search dan Filter
              _buildSearchAndFilter(),
              
              const SizedBox(height: 24),
              
              // List Profil Pegawai
              Expanded(
                child: _buildProfilList(),
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
        
        // Jabatan Filter
        Wrap(
          spacing: 8,
          children: ['Semua', 'Dosen', 'Staff', 'Rektor', 'Kepala HRD'].map((jabatan) {
            final isSelected = _selectedJabatan == jabatan;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedJabatan = jabatan;
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
                  jabatan,
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

  Widget _buildProfilList() {
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, _) {
        if (employeeProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (employeeProvider.error != null) {
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
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFE83C3C),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${employeeProvider.error}',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: const Color(0xFFE83C3C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadEmployees,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A5FBF),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Coba Lagi',
                      style: GoogleFonts.montserrat(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Filter data berdasarkan search dan jabatan
        var filteredEmployees = employeeProvider.employees.where((employee) {
          final nama = employee.namaUser.toLowerCase();
          final searchText = _searchController.text.toLowerCase();
          final jabatan = employee.profilStaf?.jabatan ?? '';
          
          final matchesSearch = _searchController.text.isEmpty || nama.contains(searchText);
          final matchesJabatan = _selectedJabatan == 'Semua' || jabatan.contains(_selectedJabatan);
          
          return matchesSearch && matchesJabatan;
        }).toList();

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
                        : 'Belum ada data profil pegawai',
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
              child: _buildProfilCard(employee),
            );
          },
        );
      },
    );
  }

  Widget _buildProfilCard(models.User employee) {
    final profil = employee.profilStaf;
    
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
          // Header dengan foto dan info dasar
          Row(
            children: [
              // Foto Profil
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5B500),
                  shape: BoxShape.circle,
                ),
                child: profil?.fotoProfil != null
                    ? ClipOval(
                        child: Image.network(
                          profil!.fotoProfil!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar(employee.namaUser);
                          },
                        ),
                      )
                    : _buildDefaultAvatar(employee.namaUser),
              ),
              
              const SizedBox(width: 16),
              
              // Info Dasar
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
                      'NIP: ${employee.nip}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    if (profil?.jabatan != null) ...[
                      Text(
                        profil!.jabatan!,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A5FBF),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: profil != null ? const Color(0xFF10B981) : const Color(0xFFF5B500),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profil != null ? 'Lengkap' : 'Belum Lengkap',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Info Detail (jika ada profil)
          if (profil != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (profil.unitKerja != null)
                    _buildInfoRow('Unit Kerja', profil.unitKerja!),
                  if (profil.jenisKelamin != null)
                    _buildInfoRow('Jenis Kelamin', profil.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan'),
                  if (profil.tempatLahir != null && profil.tanggalLahir != null)
                    _buildInfoRow('TTL', '${profil.tempatLahir}, ${_formatDate(profil.tanggalLahir!)}'),
                  if (profil.noTelepon != null)
                    _buildInfoRow('No. Telepon', profil.noTelepon!),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEditProfilModal(employee),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(
                    profil != null ? 'Edit Profil' : 'Lengkapi Profil',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5FBF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDetailProfilModal(employee),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: Text(
                    'Lihat Detail',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4A5FBF),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: Color(0xFF4A5FBF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: const Color(0xFF718096),
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 11)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: const Color(0xFF2D3748),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTambahProfilModal() {
    showDialog(
      context: context,
      builder: (context) => _buildProfilFormModal(),
    );
  }

  void _showEditProfilModal(models.User employee) {
    showDialog(
      context: context,
      builder: (context) => _buildProfilFormModal(employee: employee),
    );
  }

  void _showDetailProfilModal(models.User employee) {
    showDialog(
      context: context,
      builder: (context) => _buildDetailProfilModal(employee),
    );
  }

  Widget _buildProfilFormModal({models.User? employee}) {
    final isEdit = employee != null;
    final profil = employee?.profilStaf;
    
    // Controllers dengan data existing jika edit
    final namaController = TextEditingController(text: employee?.namaUser ?? '');
    final jabatanController = TextEditingController(text: profil?.jabatan ?? '');
    final unitKerjaController = TextEditingController(text: profil?.unitKerja ?? '');
    final tempatLahirController = TextEditingController(text: profil?.tempatLahir ?? '');
    final alamatController = TextEditingController(text: profil?.alamat ?? '');
    final noTeleponController = TextEditingController(text: profil?.noTelepon ?? '');
    
    String selectedJenisKelamin = profil?.jenisKelamin ?? 'L';
    DateTime? selectedTanggalLahir = profil?.tanggalLahir;
    DateTime? selectedTanggalMasuk = profil?.tanggalMasuk;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
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
                      isEdit ? 'Edit Profil - ${employee.namaUser}' : 'Tambah Profil Pegawai',
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
            
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (!isEdit) ...[
                      // Dropdown Pilih Pegawai (hanya untuk tambah baru)
                      _buildEmployeeDropdown(),
                      const SizedBox(height: 16),
                    ],
                    
                    _buildFormField('Nama Lengkap', namaController, enabled: !isEdit),
                    const SizedBox(height: 16),
                    _buildFormField('Jabatan', jabatanController),
                    const SizedBox(height: 16),
                    _buildFormField('Unit Kerja', unitKerjaController),
                    const SizedBox(height: 16),
                    
                    // Jenis Kelamin Dropdown
                    _buildGenderDropdown(selectedJenisKelamin, (value) {
                      selectedJenisKelamin = value;
                    }),
                    const SizedBox(height: 16),
                    
                    _buildFormField('Tempat Lahir', tempatLahirController),
                    const SizedBox(height: 16),
                    
                    // Date Pickers
                    _buildDateField('Tanggal Lahir', selectedTanggalLahir, (date) {
                      selectedTanggalLahir = date;
                    }),
                    const SizedBox(height: 16),
                    
                    _buildDateField('Tanggal Masuk', selectedTanggalMasuk, (date) {
                      selectedTanggalMasuk = date;
                    }),
                    const SizedBox(height: 16),
                    
                    _buildFormField('No. Telepon', noTeleponController),
                    const SizedBox(height: 16),
                    _buildFormField('Alamat', alamatController, maxLines: 3),
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
                        // Save profil logic here
                        Navigator.pop(context);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEdit ? 'Profil berhasil diupdate' : 'Profil berhasil ditambahkan',
                                style: GoogleFonts.montserrat(),
                              ),
                              backgroundColor: const Color(0xFF4A5FBF),
                            ),
                          );
                        }
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
                        isEdit ? 'Update' : 'Simpan',
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
    );
  }

  Widget _buildDetailProfilModal(models.User employee) {
    final profil = employee.profilStaf;
    
    return Dialog(
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
                      'Detail Profil - ${employee.namaUser}',
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
                  children: [
                    // Foto Profil
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5B500),
                        shape: BoxShape.circle,
                      ),
                      child: profil?.fotoProfil != null
                          ? ClipOval(
                              child: Image.network(
                                profil!.fotoProfil!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAvatar(employee.namaUser);
                                },
                              ),
                            )
                          : _buildDefaultAvatar(employee.namaUser),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Detail Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('NIP', employee.nip),
                          _buildDetailRow('Nama Lengkap', employee.namaUser),
                          _buildDetailRow('Jabatan', profil?.jabatan ?? '-'),
                          _buildDetailRow('Unit Kerja', profil?.unitKerja ?? '-'),
                          _buildDetailRow('Jenis Kelamin', profil?.jenisKelamin == 'L' ? 'Laki-laki' : profil?.jenisKelamin == 'P' ? 'Perempuan' : '-'),
                          _buildDetailRow('Tempat Lahir', profil?.tempatLahir ?? '-'),
                          _buildDetailRow('Tanggal Lahir', profil?.tanggalLahir != null ? _formatDate(profil!.tanggalLahir!) : '-'),
                          _buildDetailRow('Tanggal Masuk', profil?.tanggalMasuk != null ? _formatDate(profil!.tanggalMasuk!) : '-'),
                          _buildDetailRow('No. Telepon', profil?.noTelepon ?? '-'),
                          _buildDetailRow('Alamat', profil?.alamat ?? '-'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5FBF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, {bool enabled = true, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            hintStyle: GoogleFonts.montserrat(
              color: const Color(0xFF718096),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A5FBF)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: enabled ? const Color(0xFFF5F5F5) : const Color(0xFFF0F0F0),
          ),
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: enabled ? const Color(0xFF2D3748) : const Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeDropdown() {
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, _) {
        // Filter employees yang belum punya profil lengkap
        final employeesWithoutProfile = employeeProvider.employees
            .where((emp) => emp.profilStaf == null)
            .toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Pegawai',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D3748),
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
                  value: null,
                  hint: Text(
                    'Pilih pegawai...',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: const Color(0xFF718096),
                    ),
                  ),
                  isExpanded: true,
                  items: employeesWithoutProfile.map((employee) {
                    return DropdownMenuItem<String>(
                      value: employee.uuidUser,
                      child: Text(
                        '${employee.namaUser} (${employee.nip})',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    // Handle selection
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGenderDropdown(String selectedValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
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
              value: selectedValue,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'P', child: Text('Perempuan')),
              ],
              onChanged: (String? value) {
                if (value != null) onChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? selectedDate, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF4A5FBF),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate)
                        : 'Pilih $label',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: selectedDate != null
                          ? const Color(0xFF2D3748)
                          : const Color(0xFF718096),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  String _formatDate(DateTime date) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}