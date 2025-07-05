import '../core/constants.dart';

class User {
  final String uuidUser;
  final String nip;
  final String password;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relational data
  final ProfilStaf? profilStaf;

  User({
    required this.uuidUser,
    required this.nip,
    required this.password,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.profilStaf,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uuidUser: json['uuid_user'].toString(),
      nip: json['nip'].toString(),
      password: json['password'].toString(),
      role: _convertRole(json['role'].toString()),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      profilStaf: json['profil_staf'] != null && json['profil_staf'].isNotEmpty
          ? ProfilStaf.fromJson(json['profil_staf'][0])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid_user': uuidUser,
      'nip': nip,
      'password': password,
      'role': role.toString().split('.').last,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static UserRole _convertRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.hrd;
      case 'rektor':
        return UserRole.rektor;
      default:
        return UserRole.staf;
    }
  }

  // Getter untuk compatibility
  String get namaUser => profilStaf?.namaLengkap ?? 'Unknown User';
  String get email => '$nip@kampus.ac.id';
}

class ProfilStaf {
  final String uuidProfil;
  final String uuidUser;
  final String namaLengkap;
  final String? jabatan;
  final String? unitKerja;
  final DateTime? tanggalMasuk;
  final String? jenisKelamin;
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final String? alamat;
  final String? noTelepon;
  final String? fotoProfil;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfilStaf({
    required this.uuidProfil,
    required this.uuidUser,
    required this.namaLengkap,
    this.jabatan,
    this.unitKerja,
    this.tanggalMasuk,
    this.jenisKelamin,
    this.tempatLahir,
    this.tanggalLahir,
    this.alamat,
    this.noTelepon,
    this.fotoProfil,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfilStaf.fromJson(Map<String, dynamic> json) {
    return ProfilStaf(
      uuidProfil: json['uuid_profil'].toString(),
      uuidUser: json['uuid_user'].toString(),
      namaLengkap: json['nama_lengkap'].toString(),
      jabatan: json['jabatan']?.toString(),
      unitKerja: json['unit_kerja']?.toString(),
      tanggalMasuk: json['tanggal_masuk'] != null 
          ? DateTime.parse(json['tanggal_masuk'].toString()) 
          : null,
      jenisKelamin: json['jenis_kelamin']?.toString(),
      tempatLahir: json['tempat_lahir']?.toString(),
      tanggalLahir: json['tanggal_lahir'] != null 
          ? DateTime.parse(json['tanggal_lahir'].toString()) 
          : null,
      alamat: json['alamat']?.toString(),
      noTelepon: json['no_telepon']?.toString(),
      fotoProfil: json['foto_profil']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
    );
  }
}

class PengajuanCuti {
  final String uuidCuti;
  final String uuidUser;
  final String jenisCuti;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final int jumlahHari;
  final String alasan;
  final String statusPengajuan;
  final String? uuidApprover;
  final String keputusanRektor;
  final DateTime? tanggalKeputusan;
  final String? catatanRektor;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relational data
  final User? user;

  PengajuanCuti({
    required this.uuidCuti,
    required this.uuidUser,
    required this.jenisCuti,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.jumlahHari,
    required this.alasan,
    required this.statusPengajuan,
    this.uuidApprover,
    required this.keputusanRektor,
    this.tanggalKeputusan,
    this.catatanRektor,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory PengajuanCuti.fromJson(Map<String, dynamic> json) {
    return PengajuanCuti(
      uuidCuti: json['uuid_cuti'].toString(),
      uuidUser: json['uuid_user'].toString(),
      jenisCuti: json['jenis_cuti'].toString(),
      tanggalMulai: DateTime.parse(json['tanggal_mulai'].toString()),
      tanggalSelesai: DateTime.parse(json['tanggal_selesai'].toString()),
      jumlahHari: int.parse(json['jumlah_hari'].toString()),
      alasan: json['alasan'].toString(),
      statusPengajuan: json['status_pengajuan'].toString(),
      uuidApprover: json['uuid_approver']?.toString(),
      keputusanRektor: json['keputusan_rektor'].toString(),
      tanggalKeputusan: json['tanggal_keputusan'] != null 
          ? DateTime.parse(json['tanggal_keputusan'].toString()) 
          : null,
      catatanRektor: json['catatan_rektor']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      user: json['users'] != null ? User.fromJson(json['users']) : null,
    );
  }

  StatusCuti get status {
    switch (statusPengajuan.toLowerCase()) {
      case 'disetujui':
        return StatusCuti.disetujui;
      case 'ditolak':
        return StatusCuti.ditolak;
      default:
        return StatusCuti.pending;
    }
  }

  TipeCuti get tipeCuti {
    switch (jenisCuti.toLowerCase()) {
      case 'cuti sakit':
        return TipeCuti.sakit;
      case 'cuti lainnya':
        return TipeCuti.lainnya;
      default:
        return TipeCuti.tahunan;
    }
  }
}

class HakCuti {
  final String uuidHak;
  final String uuidUser;
  final String jenisCuti;
  final int totalCuti;
  final int sisaCuti;
  final int tahun;
  final DateTime createdAt;
  final DateTime updatedAt;

  HakCuti({
    required this.uuidHak,
    required this.uuidUser,
    required this.jenisCuti,
    required this.totalCuti,
    required this.sisaCuti,
    required this.tahun,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HakCuti.fromJson(Map<String, dynamic> json) {
    return HakCuti(
      uuidHak: json['uuid_hak'].toString(),
      uuidUser: json['uuid_user'].toString(),
      jenisCuti: json['jenis_cuti'].toString(),
      totalCuti: int.parse(json['total_cuti'].toString()),
      sisaCuti: int.parse(json['sisa_cuti'].toString()),
      tahun: int.parse(json['tahun'].toString()),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
    );
  }
}

class DashboardStats {
  final int totalPengajuan;
  final int menungguApproval;
  final int disetujui;
  final int ditolak;
  final List<HakCuti>? hakCuti;

  DashboardStats({
    required this.totalPengajuan,
    required this.menungguApproval,
    required this.disetujui,
    required this.ditolak,
    this.hakCuti,
  });
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Backup & Storage Models
enum BackupStatus {
  success,
  failed,
  inProgress,
}

enum BackupType {
  manual,
  automatic,
}

class BackupRecord {
  final String id;
  final String filename;
  final int fileSize;
  final BackupType type;
  final BackupStatus status;
  final DateTime createdAt;
  final String? errorMessage;

  BackupRecord({
    required this.id,
    required this.filename,
    required this.fileSize,
    required this.type,
    required this.status,
    required this.createdAt,
    this.errorMessage,
  });

  factory BackupRecord.fromJson(Map<String, dynamic> json) {
    return BackupRecord(
      id: json['id'] ?? '',
      filename: json['filename'] ?? '',
      fileSize: json['file_size'] ?? 0,
      type: BackupType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => BackupType.manual,
      ),
      status: BackupStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BackupStatus.success,
      ),
      createdAt: DateTime.parse(json['created_at']),
      errorMessage: json['error_message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'file_size': fileSize,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'error_message': errorMessage,
    };
  }
}

class StorageInfo {
  final int totalBackupSize;
  final int availableSpace;
  final int totalSpace;
  final double usagePercentage;

  StorageInfo({
    required this.totalBackupSize,
    required this.availableSpace,
    required this.totalSpace,
    required this.usagePercentage,
  });

  factory StorageInfo.fromJson(Map<String, dynamic> json) {
    return StorageInfo(
      totalBackupSize: json['total_backup_size'] ?? 0,
      availableSpace: json['available_space'] ?? 0,
      totalSpace: json['total_space'] ?? 0,
      usagePercentage: (json['usage_percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_backup_size': totalBackupSize,
      'available_space': availableSpace,
      'total_space': totalSpace,
      'usage_percentage': usagePercentage,
    };
  }
}

class AutoBackupSettings {
  final bool isEnabled;
  final String schedule;
  final int retentionDays;

  AutoBackupSettings({
    required this.isEnabled,
    required this.schedule,
    required this.retentionDays,
  });

  factory AutoBackupSettings.fromJson(Map<String, dynamic> json) {
    return AutoBackupSettings(
      isEnabled: json['is_enabled'] ?? false,
      schedule: json['schedule'] ?? '00:00',
      retentionDays: json['retention_days'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_enabled': isEnabled,
      'schedule': schedule,
      'retention_days': retentionDays,
    };
  }
}

class ExportFile {
  final String filename;
  final String path;
  final int fileSize;
  final DateTime createdAt;

  ExportFile({
    required this.filename,
    required this.path,
    required this.fileSize,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ExportFile.fromJson(Map<String, dynamic> json) {
    return ExportFile(
      filename: json['filename'] ?? '',
      path: json['path'] ?? '',
      fileSize: json['file_size'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'path': path,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
    };
  }
}