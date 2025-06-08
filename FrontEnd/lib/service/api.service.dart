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
}
