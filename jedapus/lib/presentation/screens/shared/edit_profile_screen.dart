import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math' as math;
import '../../providers.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers untuk form fields
  late TextEditingController _namaController;
  late TextEditingController _jabatanController;
  late TextEditingController _unitKerjaController;
  late TextEditingController _tempatLahirController;
  late TextEditingController _noTeleponController;
  late TextEditingController _alamatController;
  
  String? _selectedJenisKelamin;
  DateTime? _selectedTanggalLahir;
  bool _isLoading = false;
  
  // Variable untuk mobile dan desktop
  File? _selectedImage;        // Untuk mobile (Android/iOS)
  Uint8List? _webImage;        // Untuk desktop/web
  String? _currentFotoProfil;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profil = auth.currentUser?.profilStaf;
    
    _namaController = TextEditingController(text: auth.currentUser?.namaUser ?? '');
    _jabatanController = TextEditingController(text: profil?.jabatan ?? '');
    _unitKerjaController = TextEditingController(text: profil?.unitKerja ?? '');
    _tempatLahirController = TextEditingController(text: profil?.tempatLahir ?? '');
    _noTeleponController = TextEditingController(text: profil?.noTelepon ?? '');
    _alamatController = TextEditingController(text: profil?.alamat ?? '');
    
    _selectedJenisKelamin = profil?.jenisKelamin;
    _selectedTanggalLahir = profil?.tanggalLahir;
    
    // Clear image variables
    _selectedImage = null;
    _webImage = null;
    
    // Validasi foto profil sebelum assignment
    try {
      if (profil?.fotoProfil != null && profil!.fotoProfil!.isNotEmpty) {
        if (_isValidBase64(profil.fotoProfil!)) {
          _currentFotoProfil = profil.fotoProfil;
        } else {
          _currentFotoProfil = null;
          debugPrint('Invalid Base64 format for profile photo');
        }
      }
    } catch (e) {
      _currentFotoProfil = null;
      debugPrint('Error validating profile photo: $e');
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jabatanController.dispose();
    _unitKerjaController.dispose();
    _tempatLahirController.dispose();
    _noTeleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormFields(),
                  ],
                ),
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    debugPrint('_pickImage called');
    
    try {
      // Gunakan kIsWeb untuk deteksi web, dan Platform untuk mobile/desktop
      if (kIsWeb) {
        debugPrint('Platform: Web');
        await _pickImageWeb();
      } else if (Platform.isAndroid || Platform.isIOS) {
        debugPrint('Platform: Mobile (${Platform.operatingSystem})');
        await _pickImageMobile();
      } else {
        debugPrint('Platform: Desktop (${Platform.operatingSystem})');
        await _pickImageDesktop();
      }
    } catch (e) {
      debugPrint('Error in _pickImage: $e');
      _showErrorSnackBar('Error memilih gambar: $e');
    }
  }

  Future<void> _pickImageMobile() async {
    try {
      debugPrint('Starting mobile image picker');
      
      // Tampilkan dialog pilihan sumber
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;
      
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      debugPrint('Image picked: ${image?.path}');
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _webImage = null;
        });
        debugPrint('Image set successfully');
      }
    } catch (e) {
      debugPrint('Error in _pickImageMobile: $e');
      _showErrorSnackBar('Gagal memilih gambar: $e');
    }
  }

  Future<void> _pickImageDesktop() async {
    try {
      debugPrint('Starting desktop file picker');
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp'],
        allowMultiple: false,
        withData: true,
      );

      debugPrint('File picker result: ${result?.files.length ?? 0} files');

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        debugPrint('Selected file: ${file.name}, size: ${file.size}');
        
        setState(() {
          _webImage = file.bytes;
          _selectedImage = null;
        });
        debugPrint('Desktop image set successfully');
      }
    } catch (e) {
      debugPrint('Error in _pickImageDesktop: $e');
      _showErrorSnackBar('Gagal memilih gambar: $e');
    }
  }

  Future<void> _pickImageWeb() async {
    try {
      debugPrint('Starting web file picker');
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _webImage = result.files.first.bytes;
          _selectedImage = null;
        });
        debugPrint('Web image set successfully');
      }
    } catch (e) {
      debugPrint('Error in _pickImageWeb: $e');
      _showErrorSnackBar('Gagal memilih gambar: $e');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Gambar',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF4A5FBF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFF4A5FBF),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A5FBF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _convertImageToBase64(File imageFile) {
    List<int> imageBytes = imageFile.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  String _convertWebImageToBase64() {
    if (_webImage != null) {
      return base64Encode(_webImage!);
    }
    return '';
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

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4A5FBF),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: _buildImageWidget(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  debugPrint('Camera button tapped');
                  _pickImage();
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A5FBF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    // Prioritas: gambar baru > gambar existing > default avatar
    if (_webImage != null) {
      // Untuk desktop/web - tampilkan dari bytes
      return Image.memory(
        _webImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else if (_selectedImage != null) {
      // Untuk mobile - tampilkan dari file
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      // Tampilkan foto existing atau default
      return _buildExistingProfileImage();
    }
  }

  Widget _buildExistingProfileImage() {
    if (_currentFotoProfil == null || _currentFotoProfil!.isEmpty) {
      return _buildDefaultAvatar();
    }

    try {
      if (_isValidBase64(_currentFotoProfil!)) {
        return Image.memory(
          base64Decode(_currentFotoProfil!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        );
      } else {
        return _buildDefaultAvatar();
      }
    } catch (e) {
      debugPrint('Error decoding profile image: $e');
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Color(0xFF718096),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A5FBF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Menyimpan...',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Simpan',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF4A5FBF),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Edit Profile',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Container untuk foto profil
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          ),
          child: Column(
            children: [
              Text(
                'Foto Profil',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 24),
              _buildProfilePicture(),
              const SizedBox(height: 16),
              Text(
                'Ketuk ikon kamera untuk mengubah foto',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Container untuk informasi personal
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Personal',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 24),
              
              _buildTextFormField(
                controller: _namaController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _jabatanController,
                label: 'Jabatan',
                icon: Icons.work_outline,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _unitKerjaController,
                label: 'Unit Kerja',
                icon: Icons.business_outlined,
              ),
              
              const SizedBox(height: 16),
              
              _buildGenderDropdown(),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _tempatLahirController,
                label: 'Tempat Lahir',
                icon: Icons.location_on_outlined,
              ),
              
              const SizedBox(height: 16),
              
              _buildDateField(),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _noTeleponController,
                label: 'No. Telepon',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _alamatController,
                label: 'Alamat',
                icon: Icons.home_outlined,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.montserrat(
        fontSize: 14,
        color: const Color(0xFF2D3748),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          color: const Color(0xFF718096),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF4A5FBF),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A5FBF), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedJenisKelamin,
      decoration: InputDecoration(
        labelText: 'Jenis Kelamin',
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          color: const Color(0xFF718096),
        ),
        prefixIcon: const Icon(
          Icons.person_outline,
          color: Color(0xFF4A5FBF),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A5FBF), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
      ),
      items: const [
        DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
        DropdownMenuItem(value: 'P', child: Text('Perempuan')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedJenisKelamin = value;
        });
      },
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Tanggal Lahir',
            labelStyle: GoogleFonts.montserrat(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF4A5FBF),
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4A5FBF), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
          ),
          controller: TextEditingController(
            text: _selectedTanggalLahir != null 
                ? _formatDate(_selectedTanggalLahir!)
                : '',
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggalLahir ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A5FBF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D3748),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTanggalLahir) {
      setState(() {
        _selectedTanggalLahir = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Convert image to base64 berdasarkan platform
      String? fotoProfilBase64;
      
      if (_webImage != null) {
        // Untuk desktop/web - convert dari Uint8List
        fotoProfilBase64 = _convertWebImageToBase64();
      } else if (_selectedImage != null) {
        // Untuk mobile - convert dari File
        fotoProfilBase64 = _convertImageToBase64(_selectedImage!);
      } else {
        // Keep existing photo
        fotoProfilBase64 = _currentFotoProfil;
      }
      
      await authProvider.updateProfile(
        nama: _namaController.text,
        jabatan: _jabatanController.text,
        unitKerja: _unitKerjaController.text,
        jenisKelamin: _selectedJenisKelamin,
        tempatLahir: _tempatLahirController.text,
        tanggalLahir: _selectedTanggalLahir,
        noTelepon: _noTeleponController.text,
        alamat: _alamatController.text,
        fotoProfil: fotoProfilBase64,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Profile berhasil diperbarui',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF4A5FBF),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}
