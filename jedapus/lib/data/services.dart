import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'models.dart' as models;
import '../core/constants.dart';

final supabase = Supabase.instance.client;

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userRoleKey = 'user_role';

  Future<models.User?> login(String nip, String password) async {
    try {
      if (kDebugMode) {
        debugPrint('AuthService: Starting login process for NIP: $nip');
      }

      final response = await supabase
          .from('users')
          .select('*, profil_staf(*)')
          .eq('nip', nip)
          .eq('password', password)
          .eq('is_active', true)
          .maybeSingle();

      if (kDebugMode) {
        debugPrint('AuthService: User query result: $response');
      }

      if (response == null) {
        if (kDebugMode) {
          debugPrint('AuthService: No user found with NIP: $nip');
        }
        return null;
      }

      final user = models.User.fromJson(response);
      await _saveUserSession(user);

      if (kDebugMode) {
        debugPrint('AuthService: Login successful for user: ${user.namaUser}');
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Login error: $e');
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userRoleKey);
      
      if (kDebugMode) {
        debugPrint('AuthService: Logout successful - all data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Logout error: $e');
      }
    }
  }

  Future<models.User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final user = models.User.fromJson(jsonDecode(userJson));
        if (kDebugMode) {
          debugPrint('AuthService: Retrieved user from storage: ${user.namaUser}');
        }
        return user;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error getting current user: $e');
      }
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final hasToken = prefs.containsKey(_tokenKey);
      final hasUser = prefs.containsKey(_userKey);
      
      final result = isLoggedIn && hasToken && hasUser;
      
      if (kDebugMode) {
        debugPrint('AuthService: Login check - isLoggedIn: $isLoggedIn, hasToken: $hasToken, hasUser: $hasUser, result: $result');
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error checking login status: $e');
      }
      return false;
    }
  }

  Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userRoleKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error getting user role: $e');
      }
      return null;
    }
  }

  Future<models.User?> updateProfile({
    required String nama,
    String? jabatan,
    String? unitKerja,
    String? jenisKelamin,
    String? tempatLahir,
    DateTime? tanggalLahir,
    String? noTelepon,
    String? alamat,
    String? fotoProfil,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('AuthService: Starting profile update process');
      }

      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson == null) throw Exception('User not found in session');

      final user = models.User.fromJson(jsonDecode(userJson));
      final uuidUser = user.uuidUser;

      if (kDebugMode) {
        debugPrint('AuthService: Updating profile for user: $uuidUser');
      }

      await supabase.from('users').update({
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('uuid_user', uuidUser);

      final updateData = <String, dynamic>{
        'nama_lengkap': nama,
        'jabatan': jabatan,
        'unit_kerja': unitKerja,
        'jenis_kelamin': jenisKelamin,
        'tempat_lahir': tempatLahir,
        'tanggal_lahir': tanggalLahir?.toIso8601String(),
        'no_telepon': noTelepon,
        'alamat': alamat,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fotoProfil != null) {
        updateData['foto_profil'] = fotoProfil;
      }

      await supabase.from('profil_staf').update(updateData).eq('uuid_user', uuidUser);

      final response = await supabase
          .from('users')
          .select('*, profil_staf(*)')
          .eq('uuid_user', uuidUser)
          .maybeSingle();

      if (response != null) {
        final updatedUser = models.User.fromJson(response);
        await _saveUserSession(updatedUser);
        
        if (kDebugMode) {
          debugPrint('AuthService: Profile updated successfully for user: ${updatedUser.namaUser}');
        }
        
        return updatedUser;
      } else {
        throw Exception('Failed to fetch updated user');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error updating profile: $e');
      }
      throw Exception('Error updating profile: $e');
    }
  }

  Future<models.User?> updateData(String fotoProfil) async {
    try {
      if (kDebugMode) {
        debugPrint('AuthService: Starting foto profil update process');
      }

      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson == null) throw Exception('User not found in session');

      final user = models.User.fromJson(jsonDecode(userJson));
      final uuidUser = user.uuidUser;

      if (kDebugMode) {
        debugPrint('AuthService: Updating foto profil for user: $uuidUser');
      }

      await supabase.from('profil_staf').update({
        'foto_profil': fotoProfil,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('uuid_user', uuidUser);

      final response = await supabase
          .from('users')
          .select('*, profil_staf(*)')
          .eq('uuid_user', uuidUser)
          .maybeSingle();

      if (response != null) {
        final updatedUser = models.User.fromJson(response);
        await _saveUserSession(updatedUser);
        
        if (kDebugMode) {
          debugPrint('AuthService: Foto profil updated successfully');
        }
        
        return updatedUser;
      } else {
        throw Exception('Failed to fetch updated user');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error updating foto profil: $e');
      }
      throw Exception('Error updating foto profil: $e');
    }
  }

  Future<void> _saveUserSession(models.User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, 'token_${user.uuidUser}');
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_userRoleKey, user.role.toString().split('.').last);
      
      if (kDebugMode) {
        debugPrint('AuthService: User session saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error saving user session: $e');
      }
    }
  }

  Future<bool> validateToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token == null) return false;
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error validating token: $e');
      }
      return false;
    }
  }

  Future<bool> checkPassword(String nip, String prevPassword) async {
    try {
      if (kDebugMode) {
        debugPrint('AuthService: Checking previous password for NIP: $nip');
      }

      final response = await supabase
          .from('users')
          .select('uuid_user')
          .eq('nip', nip)
          .eq('password', prevPassword)
          .eq('is_active', true)
          .maybeSingle();

      final isValid = response != null;

      if (kDebugMode) {
        debugPrint('AuthService: Previous password valid: $isValid');
      }

      return isValid;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error checking previous password: $e');
      }
      return false;
    }
  }

  Future<bool> changePassword(String nip, String newPassword) async {
    try {
      if (kDebugMode) {
        debugPrint('AuthService: Changing password for NIP: $nip');
      }

      final response = await supabase
          .from('users')
          .update({
            'password': newPassword,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('nip', nip)
          .eq('is_active', true)
          .select()
          .maybeSingle();

      final isSuccess = response != null;

      if (kDebugMode) {
        debugPrint('AuthService: Password change success: $isSuccess');
      }

      return isSuccess;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error changing password: $e');
      }
      return false;
    }
  }
}

class CutiService {
  Future<List<models.PengajuanCuti>> getPengajuanCuti({
    String? userId,
    String? status,
    int? limit,
  }) async {
    try {
      PostgrestFilterBuilder query = supabase
          .from('cuti')
          .select('''
            *,
            users!cuti_uuid_user_fkey(*, profil_staf(*))
          ''');

      if (userId != null) {
        query = query.eq('uuid_user', userId);
      }

      if (status != null) {
        query = query.eq('status_pengajuan', status);
      }

      PostgrestTransformBuilder finalQuery = query.order('created_at', ascending: false);
      
      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final response = await finalQuery;
      
      return response.map<models.PengajuanCuti>((item) {
        return models.PengajuanCuti.fromJson(item);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get pengajuan cuti: $e');
    }
  }

  Future<String> createPengajuanCuti(models.PengajuanCuti pengajuan) async {
    try {
      final response = await supabase
          .from('cuti')
          .insert({
            'uuid_user': pengajuan.uuidUser,
            'jenis_cuti': pengajuan.jenisCuti,
            'tanggal_mulai': pengajuan.tanggalMulai.toIso8601String(),
            'tanggal_selesai': pengajuan.tanggalSelesai.toIso8601String(),
            'jumlah_hari': pengajuan.jumlahHari,
            'alasan': pengajuan.alasan,
            'status_pengajuan': 'Menunggu',
            'keputusan_rektor': 'Menunggu',
          })
          .select()
          .single();

      return response['uuid_cuti'].toString();
    } catch (e) {
      throw Exception('Failed to create pengajuan cuti: $e');
    }
  }

  Future<void> updateStatusPengajuan({
    required String pengajuanId,
    required String status,
    String? catatan,
    String? approvedBy,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status_pengajuan': status,
        'keputusan_rektor': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (catatan != null) {
        updateData['catatan_rektor'] = catatan;
      }

      if (approvedBy != null) {
        updateData['uuid_approver'] = approvedBy;
        updateData['tanggal_keputusan'] = DateTime.now().toIso8601String();
      }

      await supabase
          .from('cuti')
          .update(updateData)
          .eq('uuid_cuti', pengajuanId);
    } catch (e) {
      throw Exception('Failed to update status pengajuan: $e');
    }
  }

  Future<List<models.HakCuti>> getHakCuti(String userId) async {
    try {
      final response = await supabase
          .from('hak_cuti')
          .select()
          .eq('uuid_user', userId)
          .eq('tahun', DateTime.now().year);

      return response.map<models.HakCuti>((item) => models.HakCuti.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get hak cuti: $e');
    }
  }

  Future<models.DashboardStats> getDashboardStats(String userId, {UserRole? role}) async {
    try {
      PostgrestFilterBuilder totalQuery = supabase.from('cuti').select('uuid_cuti');
      if (role == UserRole.staf) {
        totalQuery = totalQuery.eq('uuid_user', userId);
      }
      final totalResponse = await totalQuery;
      final totalPengajuan = totalResponse.length;

      PostgrestFilterBuilder menungguQuery = supabase.from('cuti').select('uuid_cuti').eq('status_pengajuan', 'Menunggu');
      if (role == UserRole.staf) {
        menungguQuery = menungguQuery.eq('uuid_user', userId);
      }
      final menungguResponse = await menungguQuery;
      final menungguApproval = menungguResponse.length;

      PostgrestFilterBuilder disetujuiQuery = supabase.from('cuti').select('uuid_cuti').eq('status_pengajuan', 'Disetujui');
      if (role == UserRole.staf) {
        disetujuiQuery = disetujuiQuery.eq('uuid_user', userId);
      }
      final disetujuiResponse = await disetujuiQuery;
      final disetujui = disetujuiResponse.length;

      PostgrestFilterBuilder ditolakQuery = supabase.from('cuti').select('uuid_cuti').eq('status_pengajuan', 'Ditolak');
      if (role == UserRole.staf) {
        ditolakQuery = ditolakQuery.eq('uuid_user', userId);
      }
      final ditolakResponse = await ditolakQuery;
      final ditolak = ditolakResponse.length;

      List<models.HakCuti>? hakCuti;
      if (role == UserRole.staf) {
        hakCuti = await getHakCuti(userId);
      }

      return models.DashboardStats(
        totalPengajuan: totalPengajuan,
        menungguApproval: menungguApproval,
        disetujui: disetujui,
        ditolak: ditolak,
        hakCuti: hakCuti,
      );
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  Future<List<models.PengajuanCuti>> getPengajuanCutiWithApprover({
    String? userId,
    String? status,
    int? limit,
  }) async {
    try {
      PostgrestFilterBuilder query = supabase
          .from('cuti')
          .select('''
            *,
            users!cuti_uuid_user_fkey(*, profil_staf(*)),
            approver:users!cuti_uuid_approver_fkey(*, profil_staf(*))
          ''');

      if (userId != null) {
        query = query.eq('uuid_user', userId);
      }

      if (status != null) {
        query = query.eq('status_pengajuan', status);
      }

      PostgrestTransformBuilder finalQuery = query.order('created_at', ascending: false);
      
      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final response = await finalQuery;
      
      return response.map<models.PengajuanCuti>((item) {
        return models.PengajuanCuti.fromJson(item);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get pengajuan cuti with approver: $e');
    }
  }
}

class EmployeeService {
  Future<List<models.User>> getAllEmployees() async {
    try {
      final response = await supabase
          .from('users')
          .select('*, profil_staf(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map<models.User>((item) => models.User.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get employees: $e');
    }
  }

  // Perbaikan method createEmployee untuk mendukung fitur kelola pegawai
  Future<String> createEmployee(models.User user) async {
    try {
      if (kDebugMode) {
        debugPrint('EmployeeService: Creating employee with NIP: ${user.nip}');
      }

      // Insert ke tabel users
      final userResponse = await supabase
          .from('users')
          .insert({
            'nip': user.nip,
            'password': user.password,
            'role': user.role.toString().split('.').last,
            'is_active': true,
          })
          .select()
          .single();

      final userId = userResponse['uuid_user'].toString();

      // Insert ke tabel profil_staf jika ada data profil
      if (user.profilStaf != null) {
        await supabase.from('profil_staf').insert({
          'uuid_user': userId,
          'nama_lengkap': user.profilStaf!.namaLengkap,
          'jabatan': user.profilStaf!.jabatan,
          'unit_kerja': user.profilStaf!.unitKerja,
          'jenis_kelamin': user.profilStaf!.jenisKelamin,
          'tempat_lahir': user.profilStaf!.tempatLahir,
          'tanggal_lahir': user.profilStaf!.tanggalLahir?.toIso8601String(),
          'alamat': user.profilStaf!.alamat,
          'no_telepon': user.profilStaf!.noTelepon,
        });

        // Buat default hak cuti
        await createDefaultHakCuti(userId);
      }

      if (kDebugMode) {
        debugPrint('EmployeeService: Employee created successfully with ID: $userId');
      }

      return userId;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EmployeeService: Error creating employee: $e');
      }
      throw Exception('Failed to create employee: $e');
    }
  }

  // Perbaikan method updateEmployee untuk mendukung update profil
  Future<void> updateEmployee(models.User user) async {
    try {
      if (kDebugMode) {
        debugPrint('EmployeeService: Updating employee: ${user.uuidUser}');
      }

      // Update tabel users
      await supabase
          .from('users')
          .update({
            'nip': user.nip,
            'role': user.role.toString().split('.').last,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('uuid_user', user.uuidUser);

      // Update tabel profil_staf jika ada data profil
      if (user.profilStaf != null) {
        await supabase
            .from('profil_staf')
            .update({
              'nama_lengkap': user.profilStaf!.namaLengkap,
              'jabatan': user.profilStaf!.jabatan,
              'unit_kerja': user.profilStaf!.unitKerja,
              'jenis_kelamin': user.profilStaf!.jenisKelamin,
              'tempat_lahir': user.profilStaf!.tempatLahir,
              'tanggal_lahir': user.profilStaf!.tanggalLahir?.toIso8601String(),
              'alamat': user.profilStaf!.alamat,
              'no_telepon': user.profilStaf!.noTelepon,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('uuid_user', user.uuidUser);
      }

      if (kDebugMode) {
        debugPrint('EmployeeService: Employee updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EmployeeService: Error updating employee: $e');
      }
      throw Exception('Failed to update employee: $e');
    }
  }

  Future<void> deleteEmployee(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('EmployeeService: Soft deleting employee: $userId');
      }

      await supabase
          .from('users')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('uuid_user', userId);

      if (kDebugMode) {
        debugPrint('EmployeeService: Employee deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EmployeeService: Error deleting employee: $e');
      }
      throw Exception('Failed to delete employee: $e');
    }
  }

  Future<void> updateHakCuti(String userId, String jenisCuti, int totalCuti, int sisaCuti) async {
    try {
      if (kDebugMode) {
        debugPrint('EmployeeService: Updating hak cuti for user: $userId, jenis: $jenisCuti');
      }

      await supabase
          .from('hak_cuti')
          .update({
            'total_cuti': totalCuti,
            'sisa_cuti': sisaCuti,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('uuid_user', userId)
          .eq('jenis_cuti', jenisCuti)
          .eq('tahun', DateTime.now().year);

      if (kDebugMode) {
        debugPrint('EmployeeService: Hak cuti updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EmployeeService: Error updating hak cuti: $e');
      }
      throw Exception('Failed to update hak cuti: $e');
    }
  }

  Future<void> createProfilStaf({
    required String userId,
    required String namaLengkap,
    String? jabatan,
    String? unitKerja,
    DateTime? tanggalMasuk,
    String? jenisKelamin,
    String? tempatLahir,
    DateTime? tanggalLahir,
    String? alamat,
    String? noTelepon,
    String? fotoProfil,
  }) async {
    try {
      await supabase
          .from('profil_staf')
          .insert({
            'uuid_user': userId,
            'nama_lengkap': namaLengkap,
            'jabatan': jabatan,
            'unit_kerja': unitKerja,
            'tanggal_masuk': tanggalMasuk?.toIso8601String(),
            'jenis_kelamin': jenisKelamin,
            'tempat_lahir': tempatLahir,
            'tanggal_lahir': tanggalLahir?.toIso8601String(),
            'alamat': alamat,
            'no_telepon': noTelepon,
            'foto_profil': fotoProfil,
          });
    } catch (e) {
      throw Exception('Failed to create profil staf: $e');
    }
  }

  Future<void> createDefaultHakCuti(String userId) async {
    try {
      final hakCutiData = [
        {
          'uuid_user': userId,
          'jenis_cuti': 'Cuti Tahunan',
          'total_cuti': 24,
          'sisa_cuti': 24,
          'tahun': DateTime.now().year,
        },
        {
          'uuid_user': userId,
          'jenis_cuti': 'Cuti Sakit',
          'total_cuti': 12,
          'sisa_cuti': 12,
          'tahun': DateTime.now().year,
        },
        {
          'uuid_user': userId,
          'jenis_cuti': 'Cuti Lainnya',
          'total_cuti': 18,
          'sisa_cuti': 18,
          'tahun': DateTime.now().year,
        },
      ];

      await supabase.from('hak_cuti').insert(hakCutiData);
    } catch (e) {
      throw Exception('Failed to create default hak cuti: $e');
    }
  }

  // Method tambahan untuk mendukung fitur kelola pegawai
  Future<models.User?> getEmployeeById(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select('*, profil_staf(*)')
          .eq('uuid_user', userId)
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        return models.User.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get employee by ID: $e');
    }
  }

  Future<bool> isNipExists(String nip, {String? excludeUserId}) async {
    try {
      PostgrestFilterBuilder query = supabase
          .from('users')
          .select('uuid_user')
          .eq('nip', nip)
          .eq('is_active', true);

      if (excludeUserId != null) {
        query = query.neq('uuid_user', excludeUserId);
      }

      final response = await query.maybeSingle();
      return response != null;
    } catch (e) {
      throw Exception('Failed to check NIP existence: $e');
    }
  }

  Future<List<models.User>> getEmployeesByRole(UserRole role) async {
    try {
      final response = await supabase
          .from('users')
          .select('*, profil_staf(*)')
          .eq('role', role.toString().split('.').last)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map<models.User>((item) => models.User.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get employees by role: $e');
    }
  }

  Future<models.EmployeeStats> getEmployeeStats() async {
    try {
      // Get total employees
      final totalResponse = await supabase
          .from('users')
          .select('uuid_user, role, is_active');

      final totalEmployees = totalResponse.length;
      final activeEmployees = totalResponse.where((e) => e['is_active'] == true).length;
      final inactiveEmployees = totalEmployees - activeEmployees;

      // Count by role
      final Map<UserRole, int> employeesByRole = {};
      for (UserRole role in UserRole.values) {
        final count = totalResponse.where((e) => 
          e['role'] == role.toString().split('.').last && e['is_active'] == true
        ).length;
        employeesByRole[role] = count;
      }

      return models.EmployeeStats(
        totalEmployees: totalEmployees,
        activeEmployees: activeEmployees,
        inactiveEmployees: inactiveEmployees,
        employeesByRole: employeesByRole,
      );
    } catch (e) {
      throw Exception('Failed to get employee stats: $e');
    }
  }

  Future<void> addOrUpdateProfilStaf(String uuidUser, models.ProfilStaf profilStaf) async {
  // Cek apakah profil sudah ada
  final existing = await supabase
    .from('profil_staf')
    .select('uuid_user')
    .eq('uuid_user', uuidUser)
    .maybeSingle();

  final data = {
    'nama_lengkap': profilStaf.namaLengkap,
    'jabatan': profilStaf.jabatan,
    'unit_kerja': profilStaf.unitKerja,
    'tanggal_masuk': profilStaf.tanggalMasuk?.toIso8601String(),
    'jenis_kelamin': profilStaf.jenisKelamin,
    'tempat_lahir': profilStaf.tempatLahir,
    'tanggal_lahir': profilStaf.tanggalLahir?.toIso8601String(),
    'alamat': profilStaf.alamat,
    'no_telepon': profilStaf.noTelepon,
    'foto_profil': profilStaf.fotoProfil,
    'updated_at': DateTime.now().toIso8601String(),
  };

  if (existing != null) {
    // Jika sudah ada, lakukan update
    await supabase
      .from('profil_staf')
      .update(data)
      .eq('uuid_user', uuidUser);
  } else {
    // Jika belum ada, lakukan insert
    await supabase
      .from('profil_staf')
      .insert({
        ...data,
        'uuid_user': uuidUser,
      });
  }
}


}

class BackupService {
  Future<List<models.BackupRecord>> getBackupHistory() async {
    try {
      final response = await supabase
          .from('backup_history')
          .select()
          .order('created_at', ascending: false);

      return response.map<models.BackupRecord>((item) => models.BackupRecord.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get backup history: $e');
    }
  }

  Future<models.StorageInfo> getStorageInfo() async {
    try {
      final response = await supabase
          .from('system_info')
          .select('storage_data')
          .single();

      final storageData = response['storage_data'] as Map<String, dynamic>;
      return models.StorageInfo.fromJson(storageData);
    } catch (e) {
      return models.StorageInfo(
        totalBackupSize: 15728640,
        availableSpace: 3221225472,
        totalSpace: 3236954112,
        usagePercentage: 0.005,
      );
    }
  }

  Future<models.AutoBackupSettings> getAutoBackupSettings() async {
    try {
      final response = await supabase
          .from('system_settings')
          .select()
          .eq('setting_key', 'auto_backup')
          .maybeSingle();

      if (response != null) {
        return models.AutoBackupSettings.fromJson(response['setting_value']);
      }
      
      return models.AutoBackupSettings(
        isEnabled: true,
        schedule: '00:00',
        retentionDays: 30,
      );
    } catch (e) {
      throw Exception('Failed to get auto backup settings: $e');
    }
  }

  Future<models.BackupRecord> createBackup() async {
    try {
      final now = DateTime.now();
      final filename = 'backup_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}.sql';
      
      final response = await supabase
          .from('backup_history')
          .insert({
            'filename': filename,
            'file_size': 2500000,
            'type': 'manual',
            'status': 'success',
            'created_at': now.toIso8601String(),
          })
          .select()
          .single();

      return models.BackupRecord.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  Future<void> deleteBackup(String backupId) async {
    try {
      await supabase
          .from('backup_history')
          .delete()
          .eq('id', backupId);
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }

  Future<void> restoreFromBackup(String backupId) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      await supabase
          .from('system_logs')
          .insert({
            'action': 'restore_backup',
            'backup_id': backupId,
            'timestamp': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  Future<void> downloadBackup(String backupId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      await supabase
          .from('system_logs')
          .insert({
            'action': 'download_backup',
            'backup_id': backupId,
            'timestamp': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to download backup: $e');
    }
  }

  Future<void> setAutoBackup(bool enabled) async {
    try {
      await supabase
          .from('system_settings')
          .upsert({
            'setting_key': 'auto_backup',
            'setting_value': {
              'is_enabled': enabled,
              'schedule': '00:00',
              'retention_days': 30,
            },
            'updated_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      throw Exception('Failed to update auto backup settings: $e');
    }
  }

  Future<models.ExportFile> exportToCSV() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      
      final now = DateTime.now();
      final filename = 'export_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}.csv';
      
      return models.ExportFile(
        filename: filename,
        path: '/exports/$filename',
        fileSize: 1048576,
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }
}

// Service tambahan untuk notifikasi
class NotificationService {
  Future<List<models.NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<models.NotificationModel>((item) {
        return models.NotificationModel(
          id: item['id'].toString(),
          userId: item['user_id'].toString(),
          title: item['title'].toString(),
          message: item['message'].toString(),
          type: item['type'].toString(),
          data: item['data'] as Map<String, dynamic>?,
          isRead: item['is_read'] ?? false,
          createdAt: DateTime.parse(item['created_at'].toString()),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await supabase
          .from('notifications')
          .insert({
            'user_id': userId,
            'title': title,
            'message': message,
            'type': type,
            'data': data,
            'is_read': false,
          });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }
}

// Service untuk audit log
class AuditService {
  Future<void> logAction({
    required String userId,
    required String action,
    required String tableName,
    String? recordId,
    Map<String, dynamic>? oldValues,
    Map<String, dynamic>? newValues,
  }) async {
    try {
      await supabase
          .from('audit_logs')
          .insert({
            'user_id': userId,
            'action': action,
            'table_name': tableName,
            'record_id': recordId,
            'old_values': oldValues,
            'new_values': newValues,
            'created_at': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuditService: Error logging action: $e');
      }
    }
  }

  Future<List<models.AuditLog>> getAuditLogs({
    String? userId,
    String? tableName,
    int? limit,
  }) async {
    try {
      PostgrestFilterBuilder query = supabase
          .from('audit_logs')
          .select();

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      if (tableName != null) {
        query = query.eq('table_name', tableName);
      }

      PostgrestTransformBuilder finalQuery = query.order('created_at', ascending: false);
      
      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final response = await finalQuery;
      
      return response.map<models.AuditLog>((item) => models.AuditLog.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get audit logs: $e');
    }
  }
}
