import 'package:flutter/material.dart';

import 'bengkel_tab.dart';
import 'dashboard_tab.dart';
import 'login_screen.dart';
import 'riwayat_tab.dart';
import 'task_tab.dart';

class MainNavigation extends StatefulWidget {
  final String usernameSales;
  const MainNavigation({super.key, required this.usernameSales});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const Color primaryBlue = Color(0xFF004AAD);

  final GlobalKey<DashboardTabState> _dashboardKey =
      GlobalKey<DashboardTabState>();
  final GlobalKey<RiwayatTabState> _riwayatKey = GlobalKey<RiwayatTabState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Refresh data saat menu di-tap
    if (index == 0) {
      _dashboardKey.currentState?.refreshDashboard();
    } else if (index == 2) {
      _riwayatKey.currentState?.refreshRiwayat();
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
            Text(
              'Keluar Aplikasi?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          'Kamu akan keluar dari akun ini. Yakin ingin logout?',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.black45),
            ),
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
            child: const Text(
              'Ya, Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardTab(
        key: _dashboardKey,
        usernameSales: widget.usernameSales,
        onNavigateToTugas: () => _onItemTapped(3), // navigasi ke tab Tugas
      ),
      BengkelTab(usernameSales: widget.usernameSales),
      RiwayatTab(key: _riwayatKey, usernameSales: widget.usernameSales),
      TasksTab(username: widget.usernameSales), // Menu baru untuk Task List
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Monitoring',
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
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Bengkel'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.task_alt), label: 'Tugas'), // Ikon baru
        ],
      ),
    );
  }
}
