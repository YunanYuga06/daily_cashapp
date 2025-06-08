import 'package:daily_cashapp/service/api.service.dart';
import 'package:flutter/material.dart';
import '../models/user.model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _registerUser() async {
    final user = UserModel(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    final errorMessage = await ApiService.registerUser(user);

    if (errorMessage == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEE99C),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                ),
                child: const Center(
                  child: Text(
                    "C.",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Daftar",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Jangan terlewat pengeluaranmu,\ncatat keuanganmu mulai dari sini",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 30),
            _inputField(
              label: "Nama",
              icon: Icons.person,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            _inputField(
              label: "Email",
              icon: Icons.email,
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            _inputField(
              label: "Password",
              icon: Icons.lock,
              controller: _passwordController,
              obscure: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
                child: const Text("Sign Up"),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Sudah punya catatan? Masuk",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
