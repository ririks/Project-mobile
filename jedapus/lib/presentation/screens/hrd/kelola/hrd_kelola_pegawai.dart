import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers.dart';
import '../../../../data/models.dart' as models;
import '../../../../core/constants.dart';
import '../../../../data/services.dart';

class HRDKelolaPegawaiScreen extends StatefulWidget {
  const HRDKelolaPegawaiScreen({super.key});

  @override
  State<HRDKelolaPegawaiScreen> createState() => _HRDKelolaPegawaiScreenState();
}

class _HRDKelolaPegawaiScreenState extends State<HRDKelolaPegawaiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadPegawai();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPegawai() {
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
          'Kelola Pegawai',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showTambahPegawaiModal(),
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Pegawai',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTambahPegawaiModal(),
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
              
              // List Pegawai
              Expanded(
                child: _buildPegawaiList(),
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
              hintText: 'Cari nama atau NIP pegawai...',
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
        
        // Role Filter
        Wrap(
          spacing: 8,
          children: ['Semua', 'Staf', 'Admin', 'Rektor'].map((role) {
            final isSelected = _selectedRole == role;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRole = role;
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
                  role,
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

  Widget _buildPegawaiList() {
    return Consumer<EmployeeProvider>(
      builder: (context, employeeProvider, _) {
        if (employeeProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4A5FBF),
            ),
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
                  const Icon(Icons.error, size: 64, color: Color(0xFFE83C3C)),
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
                    onPressed: _loadPegawai,
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

        // Gunakan real data dari provider dengan filtering
        final filteredList = employeeProvider.getFilteredEmployees(
          searchQuery: _searchController.text,
          roleFilter: _selectedRole,
        );

        if (filteredList.isEmpty) {
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
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final pegawai = _convertUserToMap(filteredList[index]);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildPegawaiCard(pegawai),
            );
          },
        );
      },
    );
  }

  // Helper function untuk konversi User model ke Map
  Map<String, dynamic> _convertUserToMap(models.User user) {
    return {
      'uuid': user.uuidUser,
      'nama': user.namaUser,
      'nip': user.nip,
      'jabatan': user.profilStaf?.jabatan ?? 'Tidak ada jabatan',
      'role': user.role.label,
      'isActive': user.isActive,
      'created_at': user.createdAt.toIso8601String(),
      'password': user.password,
      'profil_uuid': user.profilStaf?.uuidProfil ?? '',
    };
  }

  // Helper function untuk konversi role string ke UserRole
  UserRole _getRoleFromString(String role) {
    switch (role) {
      case 'Admin':
        return UserRole.hrd;
      case 'Rektor':
        return UserRole.rektor;
      default:
        return UserRole.staf;
    }
  }

  Widget _buildPegawaiCard(Map<String, dynamic> pegawai) {
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
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5B500),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    pegawai['nama'][0],
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pegawai['nama'],
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      'NIP: ${pegawai['nip']} • ${pegawai['jabatan']}',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pegawai['isActive'] ? const Color(0xFF10B981) : const Color(0xFFE83C3C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pegawai['isActive'] ? 'Aktif' : 'Nonaktif',
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
          
          // Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEditPegawaiModal(pegawai),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(
                    'Edit',
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
                  onPressed: () => _showHakCutiModal(pegawai),
                  icon: const Icon(Icons.event_available, size: 16),
                  label: Text(
                    'Hak Cuti',
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
              
              const SizedBox(width: 12),
              
              IconButton(
                onPressed: () => _showDeleteConfirmation(pegawai),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFE83C3C),
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFE83C3C).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTambahPegawaiModal() {
    showDialog(
      context: context,
      builder: (context) => _buildPegawaiFormModal(),
    );
  }

  void _showEditPegawaiModal(Map<String, dynamic> pegawai) {
    showDialog(
      context: context,
      builder: (context) => _buildPegawaiFormModal(pegawai: pegawai),
    );
  }

  Widget _buildPegawaiFormModal({Map<String, dynamic>? pegawai}) {
    final isEdit = pegawai != null;
    final nipController = TextEditingController(text: pegawai?['nip'] ?? '');
    final namaController = TextEditingController(text: pegawai?['nama'] ?? '');
    final jabatanController = TextEditingController(text: pegawai?['jabatan'] ?? '');
    final passwordController = TextEditingController();
    String selectedRole = pegawai?['role'] ?? 'Staf';

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
                      isEdit ? 'Edit Pegawai' : 'Tambah Pegawai',
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
            
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildFormField('NIP', nipController),
                    const SizedBox(height: 16),
                    _buildFormField('Nama Lengkap', namaController),
                    const SizedBox(height: 16),
                    _buildFormField('Jabatan', jabatanController),
                    const SizedBox(height: 16),
                    
                    if (!isEdit) ...[
                      _buildFormField('Password', passwordController, isPassword: true),
                      const SizedBox(height: 16),
                    ],
                    
                    // Role Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Role',
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
                              value: selectedRole,
                              isExpanded: true,
                              items: ['Staf', 'Admin', 'Rektor'].map((String value) {
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
                                  selectedRole = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
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
                      onPressed: () async {
                        // Validasi input
                        if (namaController.text.isEmpty || 
                            nipController.text.isEmpty || 
                            jabatanController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Semua field wajib diisi',
                                style: GoogleFonts.montserrat(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Validasi password untuk pegawai baru
                        if (!isEdit && passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Password wajib diisi untuk pegawai baru',
                                style: GoogleFonts.montserrat(),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        try {
                          final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
                          
                          if (isEdit) {
                            // Update pegawai existing
                            final updatedUser = models.User(
                              uuidUser: pegawai!['uuid'],
                              nip: nipController.text,
                              password: pegawai!['password'] ?? 'default123',
                              role: _getRoleFromString(selectedRole),
                              isActive: true,
                              createdAt: DateTime.parse(pegawai!['created_at'] ?? DateTime.now().toIso8601String()),
                              updatedAt: DateTime.now(),
                              profilStaf: models.ProfilStaf(
                                uuidProfil: pegawai!['profil_uuid'] ?? '',
                                uuidUser: pegawai!['uuid'],
                                namaLengkap: namaController.text,
                                jabatan: jabatanController.text,
                                createdAt: DateTime.parse(pegawai!['created_at'] ?? DateTime.now().toIso8601String()),
                                updatedAt: DateTime.now(),
                              ),
                            );
                            
                            final success = await employeeProvider.updateEmployee(updatedUser);
                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Pegawai berhasil diupdate',
                                    style: GoogleFonts.montserrat(),
                                  ),
                                  backgroundColor: const Color(0xFF4A5FBF),
                                ),
                              );
                            }
                          } else {
                            // Tambah pegawai baru
                            final newUser = models.User(
                              uuidUser: '', // Will be generated by database
                              nip: nipController.text,
                              password: passwordController.text,
                              role: _getRoleFromString(selectedRole),
                              isActive: true,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              profilStaf: models.ProfilStaf(
                                uuidProfil: '',
                                uuidUser: '',
                                namaLengkap: namaController.text,
                                jabatan: jabatanController.text,
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              ),
                            );
                            
                            final success = await employeeProvider.createEmployee(newUser);
                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Pegawai berhasil ditambahkan',
                                    style: GoogleFonts.montserrat(),
                                  ),
                                  backgroundColor: const Color(0xFF4A5FBF),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Error: ${e.toString()}',
                                style: GoogleFonts.montserrat(),
                              ),
                              backgroundColor: Colors.red,
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

  Widget _buildFormField(String label, TextEditingController controller, {bool isPassword = false}) {
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
          obscureText: isPassword,
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
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
          ),
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  // PERBAIKAN UTAMA: Modal Hak Cuti dengan Data Real dari Database
  void _showHakCutiModal(Map<String, dynamic> pegawai) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
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
                            'Hak Cuti - ${pegawai['nama']}',
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
                  
                  // Content dengan FutureBuilder untuk load data real
                  Expanded(
                    child: FutureBuilder<List<models.HakCuti>>(
                      future: CutiService().getHakCuti(pegawai['uuid']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF4A5FBF),
                            ),
                          );
                        }
                        
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, size: 48, color: Color(0xFFE83C3C)),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading data: ${snapshot.error}',
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xFFE83C3C),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                        
                        final hakCutiList = snapshot.data ?? [];
                        
                        // Jika tidak ada data, tampilkan pesan dan tombol buat default
                        if (hakCutiList.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.event_busy, size: 48, color: Color(0xFF718096)),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada data hak cuti',
                                  style: GoogleFonts.montserrat(
                                    color: const Color(0xFF718096),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await EmployeeService().createDefaultHakCuti(pegawai['uuid']);
                                      setModalState(() {}); // Refresh modal
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Default hak cuti berhasil dibuat',
                                            style: GoogleFonts.montserrat(),
                                          ),
                                          backgroundColor: const Color(0xFF4A5FBF),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A5FBF),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    'Buat Default Hak Cuti',
                                    style: GoogleFonts.montserrat(),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: hakCutiList.map((hakCuti) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildHakCutiRowWithData(
                                  hakCuti, 
                                  pegawai['uuid'],
                                  () => setModalState(() {}), // Callback untuk refresh
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
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
        },
      ),
    );
  }

  // Widget untuk menampilkan hak cuti dengan data real
  Widget _buildHakCutiRowWithData(models.HakCuti hakCuti, String userId, VoidCallback onRefresh) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hakCuti.jenisCuti,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                Text(
                  'Sisa: ${hakCuti.sisaCuti} dari ${hakCuti.totalCuti} hari',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
                Text(
                  'Tahun: ${hakCuti.tahun}',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditHakCutiModalWithData(hakCuti, onRefresh),
            icon: const Icon(
              Icons.edit,
              color: Color(0xFF4A5FBF),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // Modal edit hak cuti dengan data real dan validasi lengkap
  void _showEditHakCutiModalWithData(models.HakCuti hakCuti, VoidCallback onRefresh) {
    final totalController = TextEditingController(text: hakCuti.totalCuti.toString());
    final sisaController = TextEditingController(text: hakCuti.sisaCuti.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Edit ${hakCuti.jenisCuti}',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFormField('Total Cuti', totalController),
            const SizedBox(height: 16),
            _buildFormField('Sisa Cuti', sisaController),
            const SizedBox(height: 8),
            Text(
              'Tahun: ${hakCuti.tahun}',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: const Color(0xFF718096),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF718096),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validasi input
              if (totalController.text.isEmpty || sisaController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Semua field wajib diisi',
                      style: GoogleFonts.montserrat(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final totalCuti = int.parse(totalController.text);
                final sisaCuti = int.parse(sisaController.text);

                // Validasi logika bisnis
                if (sisaCuti > totalCuti) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Sisa cuti tidak boleh lebih dari total cuti',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (totalCuti < 0 || sisaCuti < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Nilai tidak boleh negatif',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
                final success = await employeeProvider.updateHakCuti(
                  userId: hakCuti.uuidUser,
                  jenisCuti: hakCuti.jenisCuti,
                  totalCuti: totalCuti,
                  sisaCuti: sisaCuti,
                );
                
                Navigator.pop(context);
                
                if (success) {
                  onRefresh(); // Refresh modal hak cuti
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Hak cuti berhasil diupdate',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: const Color(0xFF4A5FBF),
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error: ${e.toString()}',
                      style: GoogleFonts.montserrat(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A5FBF),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.montserrat(),
            ),
          ),
        ],
      ),
    );
  }

  // Widget legacy untuk backward compatibility (tidak digunakan lagi)
  Widget _buildHakCutiRow(String jenisCuti, int sisa, int total, String userId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jenisCuti,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                Text(
                  'Sisa: $sisa dari $total hari',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditHakCutiModal(userId, jenisCuti, sisa, total),
            icon: const Icon(
              Icons.edit,
              color: Color(0xFF4A5FBF),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // Method legacy untuk backward compatibility (tidak digunakan lagi)
  void _showEditHakCutiModal(String userId, String jenisCuti, int currentSisa, int currentTotal) {
    final totalController = TextEditingController(text: currentTotal.toString());
    final sisaController = TextEditingController(text: currentSisa.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Edit $jenisCuti',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFormField('Total Cuti', totalController),
            const SizedBox(height: 16),
            _buildFormField('Sisa Cuti', sisaController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF718096),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
                final success = await employeeProvider.updateHakCuti(
                  userId: userId,
                  jenisCuti: jenisCuti,
                  totalCuti: int.parse(totalController.text),
                  sisaCuti: int.parse(sisaController.text),
                );
                
                Navigator.pop(context);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Hak cuti berhasil diupdate',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: const Color(0xFF4A5FBF),
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error: ${e.toString()}',
                      style: GoogleFonts.montserrat(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A5FBF),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.montserrat(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> pegawai) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Hapus Pegawai',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus ${pegawai['nama']}? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF718096),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
                final success = await employeeProvider.deleteEmployee(pegawai['uuid']);
                
                Navigator.pop(context);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Pegawai berhasil dihapus',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: const Color(0xFFE83C3C),
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error: ${e.toString()}',
                      style: GoogleFonts.montserrat(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE83C3C),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.montserrat(),
            ),
          ),
        ],
      ),
    );
  }
}
