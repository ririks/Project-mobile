import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard2.dart';

class InputKaryawanPage extends StatefulWidget {
  final String nik;
  final int idAdmin;

  const InputKaryawanPage({super.key, required this.nik, required this.idAdmin});

  @override
  State<InputKaryawanPage> createState() => _InputKaryawanPageState();
}

class _InputKaryawanPageState extends State<InputKaryawanPage> {
  final _formKey = GlobalKey<FormState>();
  final nikController = TextEditingController();
  final passwordController = TextEditingController();
  final namaController = TextEditingController();
  final alamatController = TextEditingController();
  final telpController = TextEditingController();
  String? selectedJkel;
  String? selectedBagian;

  List<Map<String, dynamic>> bagianList = [];

  @override
  void initState() {
    super.initState();
    fetchBagianList();
  }

  Future<void> fetchBagianList() async {
    final response = await Supabase.instance.client
        .from('bagian')
        .select()
        .order('nm_bag', ascending: true);

    setState(() {
      bagianList = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> inputKaryawan() async {
    if (!_formKey.currentState!.validate() || selectedJkel == null || selectedBagian == null) return;

    await Supabase.instance.client.from('karyawan').insert({
      'nik': nikController.text,
      'password': passwordController.text,
      'nm_karyawan': namaController.text,
      'alamat': alamatController.text,
      'j_kel': selectedJkel,
      'telp': telpController.text,
      'id_bag': int.parse(selectedBagian!),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Karyawan berhasil ditambahkan!')),
    );

    // Reset form
    nikController.clear();
    passwordController.clear();
    namaController.clear();
    alamatController.clear();
    telpController.clear();
    setState(() {
      selectedJkel = null;
      selectedBagian = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Input Karyawan')),
      drawer: AppDrawer(
        nik: widget.nik,
        idAdmin: widget.idAdmin,
        onLogout: () {
          Supabase.instance.client.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nikController,
                decoration: InputDecoration(labelText: 'NIK'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama Karyawan'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: alamatController,
                decoration: InputDecoration(labelText: 'Alamat'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                value: selectedJkel,
                items: [
                  DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedJkel = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Pilih jenis kelamin' : null,
              ),
              TextFormField(
                controller: telpController,
                decoration: InputDecoration(labelText: 'No. Telepon'),
                validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Bagian'),
                value: selectedBagian,
                items: bagianList.map((bagian) {
                  return DropdownMenuItem<String>(
                    value: bagian['id_bag'].toString(),
                    child: Text(bagian['nm_bag']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBagian = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Pilih bagian' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: inputKaryawan,
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
