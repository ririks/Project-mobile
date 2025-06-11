import 'package:flutter/material.dart';
import 'Pages/main_dashboard.dart';
import 'Pages/register_admin.dart';
import 'Pages/manage.dart';

class Dashboard2 extends StatefulWidget {
  const Dashboard2({super.key});

  @override
  State<Dashboard2> createState() => _Dashboard2State();
}

class _Dashboard2State extends State<Dashboard2> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MainDashboard(),
    const RegisterAdminPage(),
    const ManageRecipesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(['Dashboard Admin', 'Register Admin', 'Atur Resep'][_selectedIndex]),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Text('Menu Admin', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => setState(() => _selectedIndex = 0),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Register Admin'),
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            ListTile(
              leading: const Icon(Icons.food_bank),
              title: const Text('Atur Resep'),
              onTap: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
