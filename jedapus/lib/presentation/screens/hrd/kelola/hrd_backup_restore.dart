import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models.dart' as models;
import '../../../../data/services.dart';
import '../../../providers.dart';

class HRDBackupRestoreScreen extends StatefulWidget {
  const HRDBackupRestoreScreen({super.key});

  @override
  State<HRDBackupRestoreScreen> createState() => _HRDBackupRestoreScreenState();
}

class _HRDBackupRestoreScreenState extends State<HRDBackupRestoreScreen> {
  bool _isBackupInProgress = false;
  bool _isRestoreInProgress = false;
  bool _autoBackupEnabled = true;
  
  List<models.BackupRecord> _backupHistory = [];
  models.StorageInfo? _storageInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBackupData();
  }

  void _loadBackupData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load backup history from database
      final backupService = BackupService();
      final backupHistory = await backupService.getBackupHistory();
      final storageInfo = await backupService.getStorageInfo();
      final autoBackupSettings = await backupService.getAutoBackupSettings();

      setState(() {
        _backupHistory = backupHistory;
        _storageInfo = storageInfo;
        _autoBackupEnabled = autoBackupSettings.isEnabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5FBF),
        foregroundColor: Colors.white,
        title: Text(
          'Backup & Restore',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadBackupData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildErrorWidget()
                : RefreshIndicator(
                    onRefresh: () async => _loadBackupData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Actions
                          _buildQuickActionsCard(),
                          
                          const SizedBox(height: 24),
                          
                          // Storage Info
                          _buildStorageInfoCard(),
                          
                          const SizedBox(height: 24),
                          
                          // Backup History
                          _buildBackupHistoryCard(),
                          
                          const SizedBox(height: 24),
                          
                          // Automatic Backup Settings
                          _buildAutoBackupCard(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE83C3C),
            ),
            const SizedBox(height: 16),
            Text(
              'Error memuat data backup',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE83C3C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: const Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBackupData,
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

  Widget _buildQuickActionsCard() {
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
            'Aksi Cepat',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Backup Sekarang',
                  Icons.backup_outlined,
                  const Color(0xFF4A5FBF),
                  _isBackupInProgress,
                  () => _performBackup(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  'Upload Backup',
                  Icons.upload_file_outlined,
                  const Color(0xFF10B981),
                  false,
                  () => _uploadBackup(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              'Export Data CSV',
              Icons.download_outlined,
              const Color(0xFFF5B500),
              false,
              () => _exportCSV(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, bool isLoading, VoidCallback onPressed) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Icon(icon, size: 18),
        label: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildStorageInfoCard() {
    if (_storageInfo == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

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
            'Informasi Storage',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStorageItem(
                  'Total Backup',
                  _formatFileSize(_storageInfo!.totalBackupSize),
                  Icons.folder_outlined,
                  const Color(0xFF4A5FBF),
                ),
              ),
              Expanded(
                child: _buildStorageItem(
                  'Space Tersedia',
                  _formatFileSize(_storageInfo!.availableSpace),
                  Icons.storage_outlined,
                  const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Storage Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Penggunaan Storage',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF718096),
                    ),
                  ),
                  Text(
                    '${(_storageInfo!.usagePercentage * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A5FBF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _storageInfo!.usagePercentage,
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A5FBF)),
                minHeight: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 11,
              color: const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBackupHistoryCard() {
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
                'Riwayat Backup',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
              TextButton(
                onPressed: () => _showAllBackups(),
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color(0xFF4A5FBF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (_backupHistory.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.backup_outlined,
                      size: 48,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada riwayat backup',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ..._backupHistory.take(3).map((backup) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBackupItem(backup),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildBackupItem(models.BackupRecord backup) {
    Color statusColor = backup.status == models.BackupStatus.success 
        ? const Color(0xFF10B981) 
        : backup.status == models.BackupStatus.failed
            ? const Color(0xFFE83C3C)
            : const Color(0xFFF5B500);
    
    IconData statusIcon = backup.status == models.BackupStatus.success
        ? Icons.check_circle_outline
        : backup.status == models.BackupStatus.failed
            ? Icons.error_outline
            : Icons.schedule;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup.filename,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _formatDate(backup.createdAt),
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: const Color(0xFF718096),
                      ),
                    ),
                    Text(
                      ' • ${_formatFileSize(backup.fileSize)} • ${backup.type.toString().split('.').last}',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (backup.status == models.BackupStatus.success) ...[
            PopupMenuButton<String>(
              onSelected: (value) => _handleBackupAction(value, backup),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'restore',
                  child: Text('Restore'),
                ),
                const PopupMenuItem(
                  value: 'download',
                  child: Text('Download'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus'),
                ),
              ],
              child: const Icon(
                Icons.more_vert,
                color: Color(0xFF718096),
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoBackupCard() {
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
            'Backup Otomatis',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aktifkan Backup Otomatis',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    Text(
                      'Backup otomatis setiap hari pada pukul 00:00',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoBackupEnabled,
                onChanged: (value) {
                  _toggleAutoBackup(value);
                },
                activeColor: const Color(0xFF4A5FBF),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (_autoBackupEnabled) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4A5FBF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color: Color(0xFF4A5FBF),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Backup otomatis berikutnya: ${_getNextBackupTime()}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: const Color(0xFF4A5FBF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _performBackup() async {
    setState(() {
      _isBackupInProgress = true;
    });

    try {
      final backupService = BackupService();
      final backupRecord = await backupService.createBackup();
      
      // Refresh data
      _loadBackupData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Backup berhasil dibuat: ${backupRecord.filename}',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFF4A5FBF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal membuat backup: $e',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFE83C3C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackupInProgress = false;
        });
      }
    }
  }

  void _uploadBackup() {
    // Implement file picker and upload logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur upload backup akan segera tersedia',
          style: GoogleFonts.montserrat(),
        ),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _exportCSV() async {
    try {
      final backupService = BackupService();
      final csvFile = await backupService.exportToCSV();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data berhasil diekspor: ${csvFile.filename}',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFF5B500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengekspor data: $e',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFE83C3C),
          ),
        );
      }
    }
  }

  void _toggleAutoBackup(bool enabled) async {
    try {
      final backupService = BackupService();
      await backupService.setAutoBackup(enabled);
      
      setState(() {
        _autoBackupEnabled = enabled;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled ? 'Backup otomatis diaktifkan' : 'Backup otomatis dinonaktifkan',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFF4A5FBF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengubah pengaturan: $e',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFE83C3C),
          ),
        );
      }
    }
  }

  void _showAllBackups() {
    // Navigate to full backup list screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FullBackupListScreen(),
      ),
    );
  }

  void _handleBackupAction(String action, models.BackupRecord backup) {
    switch (action) {
      case 'restore':
        _showRestoreDialog(backup);
        break;
      case 'download':
        _downloadBackup(backup);
        break;
      case 'delete':
        _showDeleteDialog(backup);
        break;
    }
  }

  void _downloadBackup(models.BackupRecord backup) async {
    try {
      final backupService = BackupService();
      await backupService.downloadBackup(backup.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mengunduh ${backup.filename}',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFF4A5FBF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengunduh backup: $e',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFE83C3C),
          ),
        );
      }
    }
  }

  void _showRestoreDialog(models.BackupRecord backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Restore Database',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin restore database dari backup "${backup.filename}"? Semua data saat ini akan diganti.',
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
            onPressed: () {
              Navigator.pop(context);
              _performRestore(backup);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5B500),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Restore',
              style: GoogleFonts.montserrat(),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(models.BackupRecord backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Hapus Backup',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus backup "${backup.filename}"? Tindakan ini tidak dapat dibatalkan.',
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
            onPressed: () {
              Navigator.pop(context);
              _deleteBackup(backup);
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

  void _deleteBackup(models.BackupRecord backup) async {
    try {
      final backupService = BackupService();
      await backupService.deleteBackup(backup.id);
      
      // Refresh data
      _loadBackupData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Backup berhasil dihapus',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFE83C3C),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menghapus backup: $e',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFE83C3C),
          ),
        );
      }
    }
  }

  void _performRestore(models.BackupRecord backup) async {
    setState(() {
      _isRestoreInProgress = true;
    });

    try {
      final backupService = BackupService();
      await backupService.restoreFromBackup(backup.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Database berhasil direstore dari ${backup.filename}',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFF5B500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal restore database: $e',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: const Color(0xFFE83C3C),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoreInProgress = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _getNextBackupTime() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return 'Besok, 00:00';
  }
}

// Placeholder untuk full backup list screen
class FullBackupListScreen extends StatelessWidget {
  const FullBackupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Semua Backup',
          style: GoogleFonts.montserrat(),
        ),
      ),
      body: const Center(
        child: Text('Full backup list will be implemented here'),
      ),
    );
  }
}