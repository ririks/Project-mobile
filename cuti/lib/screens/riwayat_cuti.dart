import 'package:flutter/material.dart';

class RiwayatCutiPage extends StatefulWidget {
  const RiwayatCutiPage({super.key});

  @override
  State<RiwayatCutiPage> createState() => _RiwayatCutiPageState();
}

class _RiwayatCutiPageState extends State<RiwayatCutiPage> {
  final List<Map<String, String>> _riwayatCuti = [
    {
      'jenisCuti': 'Cuti Tahunan',
      'tanggalMulai': '01/05/2024',
      'tanggalSelesai': '05/05/2024',
      'alasan': 'Liburan keluarga ke Bali.',
      'status': 'Disetujui',
    },
    {
      'jenisCuti': 'Cuti Sakit',
      'tanggalMulai': '10/04/2024',
      'tanggalSelesai': '12/04/2024',
      'alasan': 'Demam dan flu berat.',
      'status': 'Disetujui',
    },
    {
      'jenisCuti': 'Cuti Tahunan',
      'tanggalMulai': '15/03/2024',
      'tanggalSelesai': '15/03/2024',
      'alasan': 'Mengurus keperluan pribadi.',
      'status': 'Menunggu',
    },
    {
      'jenisCuti': 'Cuti Penting Lainnya',
      'tanggalMulai': '20/02/2024',
      'tanggalSelesai': '21/02/2024',
      'alasan': 'Menghadiri pernikahan kerabat.',
      'status': 'Ditolak',
    },
    {
      'jenisCuti': 'Cuti Tahunan',
      'tanggalMulai': '01/01/2024',
      'tanggalSelesai': '07/01/2024',
      'alasan': 'Perjalanan pulang kampung.',
      'status': 'Disetujui',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _riwayatCuti.isEmpty
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
                  const SizedBox(height: 30), 
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
                  const SizedBox(height: 10),

                  ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _riwayatCuti.length,
                itemBuilder: (context, index) {
                  final cuti = _riwayatCuti[index];

                  Color statusColor;
                  switch (cuti['status']) {
                    case 'Disetujui':
                      statusColor = Colors.green;
                      break;
                    case 'Menunggu':
                      statusColor = Colors.orange;
                      break;
                    case 'Ditolak':
                      statusColor = Colors.red;
                      break;
                    default:
                      statusColor = Colors.white; // Default color
                  }

                  return Card( // This is the widget that creates the white box
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 4, // Adds a shadow to the card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounds the corners of the card
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cuti['jenisCuti']!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF424242),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15), // Background color for status
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
                                '${cuti['tanggalMulai']} - ${cuti['tanggalSelesai']}',
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
                            cuti['alasan']!,
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