import 'package:cuti/dashboard_v2/Pages/input-karyawan.dart';
import 'package:flutter/material.dart';
import 'package:cuti/dashboard_v2/pages/register_admin.dart';

class AppDrawer extends StatelessWidget {
  final int idAdmin;
  final String nik;
  final VoidCallback onLogout;

  const AppDrawer({Key? key, required this.nik, required this.onLogout, required this.idAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Admin'),
            accountEmail: Text('NIK: $nik'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: Colors.blue),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text('Register Admin'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterAdminPage(nik: nik, idAdmin: idAdmin,),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.group_add),
            title: Text('Input Karyawan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InputKaryawanPage(nik: nik, idAdmin: idAdmin,),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment),
            title: Text('Approval Page'),
            onTap: () {
              Navigator.pushNamed(context, '/approval');
            },
          ),
          Spacer(),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
