import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'admin_navigation.dart'; // import admin navigation (akan dibuat)
import 'daftar_screen.dart';
import 'main_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primaryColor = Color(0xFF004AAD);
  static const Color accentRed = Color(0xFFDB1607);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _isPasswordVisible = false;

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final authService = AuthService();
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    final result =
        await authService.login(username: username, password: password);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final success = result['status'] == 'success';
    final message = result['message']?.toString() ??
        (success ? 'Berhasil masuk.' : 'Akun tidak ditemukan.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? primaryColor : accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    if (success) {
      final String role = result['role']?.toString() ?? 'sales';

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => role == 'admin'
              ? AdminNavigation(usernameAdmin: username) // ke halaman admin
              : MainNavigation(usernameSales: username), // ke halaman sales
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 480;
    final screenPadding = isSmallScreen ? 20.0 : 32.0;
    final headingSize = isSmallScreen ? 22.0 : 26.0;
    final bodySize = isSmallScreen ? 13.0 : 14.0;
    final containerPadding = isSmallScreen ? 24.0 : 32.0;
    final maxWidth = isSmallScreen ? 400.0 : 450.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                EdgeInsets.symmetric(horizontal: screenPadding, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo_indoone.png',
                      height: isSmallScreen ? 65 : 80,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.business,
                          size: 70,
                          color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Kartu Form Login
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(containerPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Selamat Datang!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: headingSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Masuk untuk memantau performa lapangan Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black54, fontSize: bodySize),
                          ),
                          const SizedBox(height: 32),

                          // Input Username
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              prefixIcon: const Icon(Icons.person_outline,
                                  color: primaryColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: primaryColor, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Username tidak boleh kosong.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Input Password
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(() =>
                                    _isPasswordVisible = !_isPasswordVisible),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: primaryColor, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Password tidak boleh kosong.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Tombol Login
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Masuk',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                          const SizedBox(height: 24),

                          // Navigasi ke Daftar
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const DaftarScreen()),
                              );
                            },
                            style: TextButton.styleFrom(
                              overlayColor: accentRed.withOpacity(0.1),
                            ),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Belum punya akun? ',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: 'Daftar Sekarang',
                                    style: TextStyle(
                                      color: accentRed,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
