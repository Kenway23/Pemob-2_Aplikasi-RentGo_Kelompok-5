import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscure = true;
  bool _isLoading = false;

  // Controller untuk mengambil teks dari input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'penyewa';
  final List<String> _roles = ['penyewa', 'renter'];

  Future<void> _register() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field harus diisi")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Buat User di Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 2. Simpan Data ke koleksi 'user' (Sesuai gambar database kamu)
      await FirebaseFirestore.instance
          .collection('user') // Menggunakan 'user' sesuai Firestore Anda
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'nama': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'role': _selectedRole,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      // 3. Arahkan ke rute dashboard sesuai folder project
      // Pastikan rute ini terdaftar di main.dart Anda
      String route = _selectedRole == 'renter'
          ? '/renter/dashboard_renter'
          : '/penyewa/dashboard_penyewa';

      Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Registrasi Gagal")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 260,
              decoration: const BoxDecoration(
                color: Color(0xFF2E5584),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Center(
                // Pastikan path assets sudah benar di pubspec.yaml
                child: Image.asset('assets/motor.png', height: 150),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Full Name
                    TextField(
                      controller: _nameController,
                      decoration: input('Full Name', Icons.person),
                    ),
                    const SizedBox(height: 16),

                    // Email (Sudah diperbaiki controllernya)
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: input('Email', Icons.email),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Role
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          items: _roles.map((String role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(
                                role == 'penyewa'
                                    ? 'Daftar sebagai Penyewa'
                                    : 'Daftar sebagai Renter (Pemilik)',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedRole = value!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextField(
                      controller: _passwordController,
                      obscureText: obscure,
                      decoration: input(
                        'Password',
                        Icons.lock,
                        suffix: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Button Register
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        // Panggil fungsi _register jika tidak sedang loading
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Register'),
                      ),
                    ),

                    // Tombol Balik ke Login
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Sudah punya akun? Login di sini'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration input(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF5F7FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
