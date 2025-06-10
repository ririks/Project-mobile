import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatCutiPage extends StatefulWidget {
  final int? idUser; 

  const RiwayatCutiPage({super.key, this.idUser});

  @override
  State<RiwayatCutiPage> createState() => _RiwayatCutiPageState();
}

class _RiwayatCutiPageState extends State<RiwayatCutiPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _riwayatCuti = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRiwayatCuti();
  }

  Future<void> _fetchRiwayatCuti() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Map<String, dynamic>> rawData;

      if (widget.idUser != null) {
        rawData = await supabase
            .from('cuti')
            .select('*')
            .eq('id_karyawan', widget.idUser!)
            .order('tgl', ascending: false);
      } else {
        rawData = await supabase
            .from('cuti')
            .select('*')
            .order('tgl', ascending: false);
      }

      setState(() {
        _riwayatCuti = rawData;
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
      print('Error fetching riwayat cuti: ${e.message}');
      setState(() {
        _errorMessage = 'Gagal memuat riwayat cuti: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      print('Unexpected error fetching riwayat cuti: $e');
      setState(() {
        _errorMessage = 'Terjadi kesalahan tidak terduga: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDateManual(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      List<String> parts = dateString.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (e) {
      print('Failed to manually format date: $e');
    }
    return dateString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFDD835)),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 80, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.red[700]),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _fetchRiwayatCuti,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFDD835),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _riwayatCuti.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada riwayat cuti.',
                            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ajukan cuti pertama Anda sekarang!',
                            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(height: 10),
                          const Text(
                            'Cek semua riwayat cuti kamu di sini!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Lihat status dan detail setiap pengajuan cuti.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _riwayatCuti.length,
                            itemBuilder: (context, index) {
                              final cuti = _riwayatCuti[index];

                              Color statusColor = Colors.orange; 
                              switch (cuti['status']) {
                                case 'Diterima':
                                  statusColor = Colors.green;
                                  break;
                                case 'Ditolak':
                                  statusColor = Colors.red;
                                  break;
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              cuti['nm_cuti']!,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF424242),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              cuti['status']!,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(Icons.date_range_outlined, size: 18, color: Colors.grey[600]),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${_formatDateManual(cuti['tgl_mulai']?.toString())} - ${_formatDateManual(cuti['tgl_selesai']?.toString())}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Alasan:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        cuti['alasan'] ?? 'Tidak ada alasan',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }
}