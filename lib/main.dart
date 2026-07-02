import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const MonitoringSalesApp());
}

class MonitoringSalesApp extends StatelessWidget {
  const MonitoringSalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sales Field Monitoring',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF004AAD),
      ),
      home: const LoginScreen(),
    );
  }
}
