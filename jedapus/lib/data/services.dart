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

  // Validasi token (opsional)
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

      // Apply ordering dan limit
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
      // Get total pengajuan
      PostgrestFilterBuilder totalQuery = supabase.from('cuti').select('uuid_cuti');
      if (role == UserRole.staf) {
        totalQuery = totalQuery.eq('uuid_user', userId);
      }
      final totalResponse = await totalQuery;
      final totalPengajuan = totalResponse.length;

      // Get menunggu approval
      PostgrestFilterBuilder menungguQuery = supabase.from('cuti').select('uuid_cuti').eq('status_pengajuan', 'Menunggu');
      if (role == UserRole.staf) {
        menungguQuery = menungguQuery.eq('uuid_user', userId);
      }
      final menungguResponse = await menungguQuery;
      final menungguApproval = menungguResponse.length;

      // Get disetujui
      PostgrestFilterBuilder disetujuiQuery = supabase.from('cuti').select('uuid_cuti').eq('status_pengajuan', 'Disetujui');
      if (role == UserRole.staf) {
        disetujuiQuery = disetujuiQuery.eq('uuid_user', userId);
      }
      final disetujuiResponse = await disetujuiQuery;
      final disetujui = disetujuiResponse.length;

      // Get ditolak
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

  Future<String> createEmployee(models.User user) async {
    try {
      final response = await supabase
          .from('users')
          .insert({
            'nip': user.nip,
            'password': user.password,
            'role': user.role.toString().split('.').last,
            'is_active': true,
          })
          .select()
          .single();

      return response['uuid_user'].toString();
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  Future<void> updateEmployee(models.User user) async {
    try {
      await supabase
          .from('users')
          .update({
            'nip': user.nip,
            'role': user.role.toString().split('.').last,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('uuid_user', user.uuidUser);
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  Future<void> deleteEmployee(String userId) async {
    try {
      await supabase
          .from('users')
          .update({'is_active': false})
          .eq('uuid_user', userId);
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  Future<void> updateHakCuti(String userId, String jenisCuti, int totalCuti, int sisaCuti) async {
    try {
      await supabase
          .from('hak_cuti')
          .update({
            'total_cuti': totalCuti,
            'sisa_cuti': sisaCuti,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('uuid_user', userId)
          .eq('jenis_cuti', jenisCuti);
    } catch (e) {
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
      // Simulate restore process
      await Future.delayed(const Duration(seconds: 2));
      
      // Log restore action
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
      // Simulate download process
      await Future.delayed(const Duration(seconds: 1));
      
      // Log download action
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