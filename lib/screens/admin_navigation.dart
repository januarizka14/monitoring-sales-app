import 'package:flutter/material.dart';

import 'admin_dashboard_tab.dart';
import 'admin_kunjungan_tab.dart';
import 'admin_tugas_tab.dart';
import 'admin_users_tab.dart';
import 'login_screen.dart';

class AdminNavigation extends StatefulWidget {
  final String usernameAdmin;
  const AdminNavigation({super.key, required this.usernameAdmin});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _selectedIndex = 0;
  static const Color primaryBlue = Color(0xFF004AAD);

  final GlobalKey<AdminDashboardTabState> _dashboardKey =
      GlobalKey<AdminDashboardTabState>();

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    // Refresh dashboard setiap kali tab Dashboard di-tap
    if (index == 0) {
      _dashboardKey.currentState?.refreshDashboard();
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFDB1607)),
            SizedBox(width: 10),
            Text('Keluar Aplikasi?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Kamu akan keluar dari akun admin. Yakin ingin logout?',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.black45)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDB1607),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child:
                const Text('Ya, Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      AdminDashboardTab(
          key: _dashboardKey, usernameAdmin: widget.usernameAdmin),
      AdminTugasTab(usernameAdmin: widget.usernameAdmin),
      AdminKunjunganTab(),
      AdminUsersTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded), label: 'Tugas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded), label: 'Kunjungan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded), label: 'Users'),
        ],
      ),
    );
  }
}
