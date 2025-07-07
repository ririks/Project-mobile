import 'package:flutter/foundation.dart';
import '../data/models.dart' as models;
import '../data/services.dart';
import '../core/constants.dart';

class AuthProvider extends ChangeNotifier {
  models.User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  models.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  String? get currentUserFotoProfil => _currentUser?.profilStaf?.fotoProfil;
  bool get hasProfilePhoto => currentUserFotoProfil != null && currentUserFotoProfil!.isNotEmpty;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('AuthProvider: Initializing authentication...');
      }

      final isLoggedIn = await AuthService().isLoggedIn();
      
      if (isLoggedIn) {
        final user = await AuthService().getCurrentUser();
        if (user != null) {
          _currentUser = user;
          _isAuthenticated = true;
          
          if (kDebugMode) {
            debugPrint('AuthProvider: User auto-logged in: ${user.namaUser}, role: ${user.role}');
          }
        } else {
          // Data tidak konsisten, logout
          await _clearSession();
        }
      } else {
        if (kDebugMode) {
          debugPrint('AuthProvider: No valid session found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthProvider: Error initializing auth: $e');
      }
      await _clearSession();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Method untuk re-check auth status (dipanggil dari app.dart)
  Future<void> checkAuthStatus() async {
    await _initializeAuth();
  }

  Future<bool> login(String nip, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('AuthProvider: Attempting login with NIP: $nip');
      }
      
      final user = await AuthService().login(nip, password);
      
      if (user != null) {
        if (kDebugMode) {
          debugPrint('AuthProvider: Login successful, user: ${user.namaUser}, role: ${user.role}');
        }
        _currentUser = user;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthProvider: Login error: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      if (kDebugMode) {
        debugPrint('AuthProvider: Logging out user: ${_currentUser?.namaUser}');
      }
      
      await AuthService().logout();
      await _clearSession();
      
      if (kDebugMode) {
        debugPrint('AuthProvider: Logout completed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthProvider: Logout error: $e');
      }
    }
  }

  Future<void> _clearSession() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> checkPassword(String nip, String prevPassword) async {
    try {
      return await AuthService().checkPassword(nip, prevPassword);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthProvider: Error checking password: $e');
      }
      return false;
    }
  }

  Future<bool> changePassword(String nip, String newPassword) async {
    try {
      return await AuthService().changePassword(nip, newPassword);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthProvider: Error changing password: $e');
      }
      return false;
    }
  }

  // Method untuk refresh user data
  Future<void> refreshUser() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthProvider: Error refreshing user: $e');
      }
    }
  }

  // Method untuk update profile tanpa foto
  Future<void> updateProfile({
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
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('AuthProvider: Updating profile for user: ${_currentUser?.namaUser}');
      }

      final updatedUser = await AuthService().updateProfile(
        nama: nama,
        jabatan: jabatan,
        unitKerja: unitKerja,
        jenisKelamin: jenisKelamin,
        tempatLahir: tempatLahir,
        tanggalLahir: tanggalLahir,
        noTelepon: noTelepon,
        alamat: alamat,
        fotoProfil: fotoProfil,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        
        if (kDebugMode) {
          debugPrint('AuthProvider: Profile updated successfully for user: ${updatedUser.namaUser}');
        }
      } else {
        throw Exception('Gagal memperbarui profil - response null');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthProvider: Error updating profile: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method khusus untuk update foto profil saja
  Future<void> updateFotoProfil(String fotoProfil) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('AuthProvider: Updating foto profil for user: ${_currentUser?.namaUser}');
      }

      final updatedUser = await AuthService().updateData(fotoProfil);

      if (updatedUser != null) {
        _currentUser = updatedUser;
        
        if (kDebugMode) {
          debugPrint('AuthProvider: Foto profil updated successfully');
        }
      } else {
        throw Exception('Gagal memperbarui foto profil - response null');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthProvider: Error updating foto profil: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method untuk mendapatkan foto profil dalam format yang siap digunakan
  String? getProfilePhotoBase64() {
    if (hasProfilePhoto) {
      return currentUserFotoProfil;
    }
    return null;
  }
}

class DashboardProvider extends ChangeNotifier {
  models.DashboardStats? _stats;
  List<models.PengajuanCuti> _recentPengajuan = [];
  bool _isLoading = false;
  String? _error;

  models.DashboardStats? get stats => _stats;
  List<models.PengajuanCuti> get recentPengajuan => _recentPengajuan;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboardData(String userId, UserRole role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await CutiService().getDashboardStats(userId, role: role);
      _recentPengajuan = await CutiService().getPengajuanCuti(
        userId: role == UserRole.staf ? userId : null,
        limit: 5,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void refresh(String userId, UserRole role) {
    loadDashboardData(userId, role);
  }

  // Method untuk clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

class CutiProvider extends ChangeNotifier {
  List<models.PengajuanCuti> _pengajuanList = [];
  final List<models.HakCuti> _hakCuti = [];
  bool _isLoading = false;
  String? _error;

  List<models.PengajuanCuti> get pengajuanList => _pengajuanList;
  List<models.HakCuti> get hakCuti => _hakCuti;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPengajuanCuti({String? userId, String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pengajuanList = await CutiService().getPengajuanCuti(
        userId: userId,
        status: status,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateStatus({
    required String pengajuanId,
    required String status,
    String? catatan,
    String? approvedBy,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await CutiService().updateStatusPengajuan(
        pengajuanId: pengajuanId,
        status: status,
        catatan: catatan,
        approvedBy: approvedBy,
      );
      
      await loadPengajuanCuti();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPengajuan({
    required String userId,
    required String jenisCuti,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    required String alasan,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jumlahHari = tanggalSelesai.difference(tanggalMulai).inDays + 1;
      
      final pengajuan = models.PengajuanCuti(
        uuidCuti: '', // Will be generated by database
        uuidUser: userId,
        jenisCuti: jenisCuti,
        tanggalMulai: tanggalMulai,
        tanggalSelesai: tanggalSelesai,
        jumlahHari: jumlahHari,
        alasan: alasan,
        statusPengajuan: 'Menunggu',
        keputusanRektor: 'Menunggu',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await CutiService().createPengajuanCuti(pengajuan);
      await loadPengajuanCuti(userId: userId);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadHakCuti(String userId) async {
    try {
      final hakCutiList = await CutiService().getHakCuti(userId);
      _hakCuti.clear();
      _hakCuti.addAll(hakCutiList);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Method untuk clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Method untuk filter pengajuan berdasarkan status
  List<models.PengajuanCuti> getFilteredPengajuan(String? statusFilter) {
    if (statusFilter == null || statusFilter == 'Semua') {
      return _pengajuanList;
    }
    return _pengajuanList.where((p) => p.statusPengajuan == statusFilter).toList();
  }
}

class EmployeeProvider extends ChangeNotifier {
  List<models.User> _employees = [];
  bool _isLoading = false;
  String? _error;
  models.EmployeeStats? _stats;

  List<models.User> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;
  models.EmployeeStats? get stats => _stats;

  Future<void> loadEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await EmployeeService().getAllEmployees();
      
      // Load statistics
      _stats = await EmployeeService().getEmployeeStats();
      
      if (kDebugMode) {
        debugPrint('EmployeeProvider: Loaded ${_employees.length} employees');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('EmployeeProvider: Error loading employees: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createEmployee(models.User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validasi NIP unik
      final nipExists = await EmployeeService().isNipExists(user.nip);
      if (nipExists) {
        _error = 'NIP ${user.nip} sudah digunakan';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await EmployeeService().createEmployee(user);
      await loadEmployees(); // Refresh list
      
      if (kDebugMode) {
        debugPrint('EmployeeProvider: Employee created successfully');
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('EmployeeProvider: Error creating employee: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addOrUpdateProfilStaf({
  required String uuidUser,
  required models.ProfilStaf profilStaf,
  }) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    await EmployeeService().addOrUpdateProfilStaf(uuidUser, profilStaf);
    await loadEmployees(); // Refresh data
    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
    return false;
  }
}


  Future<bool> updateEmployee(models.User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validasi NIP unik (exclude current user)
      final nipExists = await EmployeeService().isNipExists(user.nip, excludeUserId: user.uuidUser);
      if (nipExists) {
        _error = 'NIP ${user.nip} sudah digunakan oleh pegawai lain';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await EmployeeService().updateEmployee(user);
      await loadEmployees(); // Refresh list
      
      if (kDebugMode) {
        debugPrint('EmployeeProvider: Employee updated successfully');
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('EmployeeProvider: Error updating employee: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEmployee(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await EmployeeService().deleteEmployee(userId);
      await loadEmployees(); // Refresh list
      
      if (kDebugMode) {
        debugPrint('EmployeeProvider: Employee deleted successfully');
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('EmployeeProvider: Error deleting employee: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateHakCuti({
    required String userId,
    required String jenisCuti,
    required int totalCuti,
    required int sisaCuti,
  }) async {
    try {
      await EmployeeService().updateHakCuti(userId, jenisCuti, totalCuti, sisaCuti);
      await loadEmployees(); // Refresh list
      
      if (kDebugMode) {
        debugPrint('EmployeeProvider: Hak cuti updated successfully');
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('EmployeeProvider: Error updating hak cuti: $e');
      }
      notifyListeners();
      return false;
    }
  }

  List<models.User> getFilteredEmployees({String? searchQuery, String? roleFilter}) {
    List<models.User> filtered = List.from(_employees);

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final name = user.namaUser.toLowerCase();
        final nip = user.nip.toLowerCase();
        final query = searchQuery.toLowerCase();
        return name.contains(query) || nip.contains(query);
      }).toList();
    }

    // Filter by role
    if (roleFilter != null && roleFilter != 'Semua') {
      UserRole targetRole;
      switch (roleFilter) {
        case 'Admin':
          targetRole = UserRole.hrd;
          break;
        case 'Rektor':
          targetRole = UserRole.rektor;
          break;
        default:
          targetRole = UserRole.staf;
      }
      filtered = filtered.where((user) => user.role == targetRole).toList();
    }

    return filtered;
  }

  // Method untuk mendapatkan employee berdasarkan ID
  models.User? getEmployeeById(String userId) {
    try {
      return _employees.firstWhere((emp) => emp.uuidUser == userId);
    } catch (e) {
      return null;
    }
  }

  // Method untuk clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Method untuk mendapatkan employees berdasarkan role
  List<models.User> getEmployeesByRole(UserRole role) {
    return _employees.where((emp) => emp.role == role).toList();
  }

  // Method untuk refresh data tanpa loading indicator
  Future<void> refreshData() async {
    try {
      _employees = await EmployeeService().getAllEmployees();
      _stats = await EmployeeService().getEmployeeStats();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EmployeeProvider: Error refreshing data: $e');
      }
    }
  }
}

class NotificationProvider extends ChangeNotifier {
  final List<models.NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<models.NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Gunakan NotificationService untuk load real data
      final notificationList = await NotificationService().getNotifications(userId);
      _notifications.clear();
      _notifications.addAll(notificationList);
      
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      
      if (kDebugMode) {
        debugPrint('NotificationProvider: Loaded ${_notifications.length} notifications, ${_unreadCount} unread');
      }
    } catch (e) {
      _error = e.toString();
      
      // Fallback ke mock data jika service belum tersedia
      _notifications.clear();
      _notifications.addAll([
        models.NotificationModel(
          id: '1',
          userId: userId,
          title: 'Pengajuan Cuti Disetujui',
          message: 'Pengajuan cuti tahunan Anda telah disetujui',
          type: 'approval',
          isRead: false,
          createdAt: DateTime.now(),
        ),
        models.NotificationModel(
          id: '2',
          userId: userId,
          title: 'Pengingat Cuti',
          message: 'Anda memiliki 8 hari cuti tahunan tersisa',
          type: 'reminder',
          isRead: true,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ]);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      
      if (kDebugMode) {
        debugPrint('NotificationProvider: Using mock data due to error: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await NotificationService().markAsRead(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      // Fallback ke local update
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
      
      if (kDebugMode) {
        debugPrint('NotificationProvider: Error marking as read: $e');
      }
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // Mark all as read di server
      for (final notification in _notifications.where((n) => !n.isRead)) {
        await NotificationService().markAsRead(notification.id);
      }
      
      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      // Fallback ke local update
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      _unreadCount = 0;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('NotificationProvider: Error marking all as read: $e');
      }
    }
  }

  Future<void> addNotification(models.NotificationModel notification) async {
    try {
      await NotificationService().createNotification(
        userId: notification.userId,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        data: notification.data,
      );
      
      _notifications.insert(0, notification);
      if (!notification.isRead) {
        _unreadCount++;
      }
      notifyListeners();
    } catch (e) {
      // Fallback ke local add
      _notifications.insert(0, notification);
      if (!notification.isRead) {
        _unreadCount++;
      }
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('NotificationProvider: Error adding notification: $e');
      }
    }
  }

  Future<void> removeNotification(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications.removeAt(index);
      if (!notification.isRead) {
        _unreadCount--;
      }
      notifyListeners();
    }
  }

  // Method untuk clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Method untuk filter notifications berdasarkan type
  List<models.NotificationModel> getFilteredNotifications(String? typeFilter) {
    if (typeFilter == null || typeFilter == 'all') {
      return _notifications;
    }
    return _notifications.where((n) => n.type == typeFilter).toList();
  }

  // Method untuk mendapatkan unread notifications saja
  List<models.NotificationModel> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }
}

// Provider tambahan untuk Backup & Storage
class BackupProvider extends ChangeNotifier {
  List<models.BackupRecord> _backupHistory = [];
  models.StorageInfo? _storageInfo;
  models.AutoBackupSettings? _autoBackupSettings;
  bool _isLoading = false;
  String? _error;

  List<models.BackupRecord> get backupHistory => _backupHistory;
  models.StorageInfo? get storageInfo => _storageInfo;
  models.AutoBackupSettings? get autoBackupSettings => _autoBackupSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBackupData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _backupHistory = await BackupService().getBackupHistory();
      _storageInfo = await BackupService().getStorageInfo();
      _autoBackupSettings = await BackupService().getAutoBackupSettings();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBackup() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newBackup = await BackupService().createBackup();
      _backupHistory.insert(0, newBackup);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBackup(String backupId) async {
    try {
      await BackupService().deleteBackup(backupId);
      _backupHistory.removeWhere((backup) => backup.id == backupId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> setAutoBackup(bool enabled) async {
    try {
      await BackupService().setAutoBackup(enabled);
      if (_autoBackupSettings != null) {
        _autoBackupSettings = models.AutoBackupSettings(
          isEnabled: enabled,
          schedule: _autoBackupSettings!.schedule,
          retentionDays: _autoBackupSettings!.retentionDays,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
