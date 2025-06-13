import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard2.dart';

class RegisterAdminPage extends StatefulWidget {
  final String nik;
  final int idAdmin;
  
  const RegisterAdminPage({super.key, required this.nik, required this.idAdmin,});

  @override
  State<RegisterAdminPage> createState() => _RegisterAdminPageState();
}

class _RegisterAdminPageState extends State<RegisterAdminPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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

  Future<void> registerAdmin() async {
    if (!_formKey.currentState!.validate() || selectedBagian == null) return;

    await Supabase.instance.client.from('admin').insert({
      'nik': nikController.text,
      'password': passwordController.text,
      'id_bag': selectedBagian,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Admin berhasil didaftarkan!')),
    );

    nikController.clear();
    passwordController.clear();
    setState(() {
      selectedBagian = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register Admin")),
      drawer: AppDrawer(
        nik: widget.nik,
        idAdmin: widget.idAdmin,
        onLogout: () {
          Supabase.instance.client.auth.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
              DropdownButtonFormField<String>(
                value: selectedBagian,
                decoration: InputDecoration(labelText: 'Bagian'),
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
                    value == null ? 'Pilih salah satu bagian' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: registerAdmin,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
