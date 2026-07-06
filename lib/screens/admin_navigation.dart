import 'package:flutter/material.dart';

import 'admin_dashboard_tab.dart';
import 'admin_kunjungan_tab.dart';
import 'admin_tugas_tab.dart';
import 'admin_users_tab.dart';

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
