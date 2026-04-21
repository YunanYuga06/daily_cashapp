// lib/pages/halaman_crud/edit_profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/api.service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  // Di dalam fungsi saat user memilih gambar profil:
  
  File? _imageFile;
  String? _networkImageUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Token tidak ditemukan");

      final user = await ApiService.getCurrentUser(token);
      if (mounted) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _networkImageUrl = user.imageUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception("Token tidak ditemukan");

      final success = await ApiService.updateUserProfile(
        token: token,
        name: _nameController.text,
        imageFile: _imageFile,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        Navigator.pop(context, true); // Kirim 'true' untuk refresh halaman profil
      } else {
        throw Exception("Gagal menyimpan data ke server.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan profil: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (_networkImageUrl != null && _networkImageUrl!.isNotEmpty
                                ? NetworkImage(_networkImageUrl!)
                                : null) as ImageProvider?,
                        child: _imageFile == null && (_networkImageUrl == null || _networkImageUrl!.isEmpty)
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  readOnly: true, // Email tidak bisa diubah
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,))
                      : const Text('SIMPAN PERUBAHAN'),
                ),
              ],
            ),
    );
  }
}