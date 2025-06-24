// lib/pages/profile_page.dart
import 'package:daily_cashapp/pages/halaman_crud/edit_profile.dart';
import 'package:daily_cashapp/view/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import '../service/api.service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<ProfileModel> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _userFuture = _fetchUser();
    });
  }

  Future<ProfileModel> _fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      // Jika tidak ada token, paksa logout
      _logout();
      throw Exception("Sesi berakhir. Silakan login kembali.");
    }
    return ApiService.getCurrentUser(token);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const DashboardPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ProfileModel>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat profil: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Data profil tidak ditemukan.'));
          }

          final user = snapshot.data!;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  _buildProfileHeader(user),
                  const SizedBox(height: 36),
                  _buildProfileButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(ProfileModel user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
              ? NetworkImage(user.imageUrl!)
              : null,
          child: (user.imageUrl == null || user.imageUrl!.isEmpty)
              ? const Icon(Icons.person, size: 38, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAEA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButtons() {
    return Column(
      children: [
        _buildButton(
          icon: Icons.edit,
          text: 'Edit Profile',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfilePage()),
            );
            if (result == true) {
              _loadUserData();
            }
          },
        ),
        const SizedBox(height: 16),
        _buildButton(
          icon: Icons.settings,
          text: 'Pengaturan',
          onPressed: () {
            // TODO: Navigasi ke halaman pengaturan
          },
        ),
        const SizedBox(height: 16),
        _buildButton(
          icon: Icons.logout,
          text: 'Logout',
          onPressed: _logout,
          color: const Color(0xFFFFCC2A),
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: Colors.black),
        label: Text(text, style: const TextStyle(color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color(0xFFFEF9ED),
          side: const BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}