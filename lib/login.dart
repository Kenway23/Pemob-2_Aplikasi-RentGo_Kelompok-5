import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscure = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      print("LOGIN: auth start with email=$email");

      if (email.isEmpty || password.isEmpty) {
        throw Exception("Email dan password tidak boleh kosong");
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print("LOGIN: auth success: ${userCredential.user?.uid}");

      final userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(userCredential.user!.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      print("LOGIN: firestore fetched: ${userDoc.exists}");

      if (!mounted) return;

      if (!userDoc.exists) {
        throw Exception("Dokumen user tidak ditemukan di Firestore");
      }

      final role = userDoc['role'];
      print("LOGIN: role = $role");

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin/dashboard_admin');
      } else if (role == 'renter') {
        Navigator.pushReplacementNamed(context, '/renter/dashboard_renter');
      } else {
        Navigator.pushReplacementNamed(context, '/penyewa/dashboard_penyewa');
      }
    } on FirebaseAuthException catch (e, st) {
      print(
        'LOGIN: FirebaseAuthException: code=${e.code}, message=${e.message}',
      );
      print('Stack: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth error: ${e.message ?? e.code}')),
      );
    } on FirebaseException catch (e, st) {
      print('LOGIN: FirebaseException: ${e.message}');
      print('Stack: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Firebase error: ${e.message}')));
    } catch (e, st) {
      print('LOGIN: Exception: $e');
      print('Stack: $st');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                child: Image.asset('assets/img/mobil.png', height: 150),
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
                      'Welcome',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: input('Email', Icons.email),
                    ),
                    const SizedBox(height: 16),
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
                          onPressed: () {
                            setState(() => obscure = !obscure);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('Login'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text('Create Account'),
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
