import 'dart:convert';
import 'package:daily_cashapp/config/env.dart';
import 'package:http/http.dart' as http;
import '../models/user.model.dart';

class ApiService {
  static Future<String?> registerUser(UserModel user) async {
    final url = Uri.parse('${Env.baseUrl}/users');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return null; // berhasil, tidak ada error
    } else {
      return "Error: ${response.body}";
    }
  }

  static Future<String?> loginUser(String email, String password) async {
    final url = Uri.parse('${Env.baseUrl}/users/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Bisa langsung return token kalau ingin pakai lokal variabel saja
      final jsonResponse = jsonDecode(response.body);
      final name = jsonResponse['data']['name'];
      final token = jsonResponse['data']['token'];

      return null;
    } else {
      return "Login gagal: ${response.body}";
    }
  }
}
