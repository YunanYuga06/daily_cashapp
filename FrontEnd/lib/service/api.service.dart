// daily_cashapp/FrontEnd/lib/service/api.service.dart

import 'dart:convert';
import 'package:daily_cashapp/config/env.dart';
import 'package:http/http.dart' as http;
import '../models/user.model.dart';
import '../models/asset_model.dart';
import '../models/budget.dart';
import '../models/transaksi_model.dart';

class ApiService {
  static Future<String?> registerUser(UserModel user) async {
    final url = Uri.parse('${Env.baseUrl}/users');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return null;
    } else {
      final errorBody = jsonDecode(response.body);
      return "Error: ${errorBody['errors'] ?? 'Gagal mendaftar'}";
    }
  }


  static Future<String?> loginUser(String email, String password) async {
    final url = Uri.parse('${Env.baseUrl}/users/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final token = jsonResponse['data']['token'] as String;
      return token;
    } else {
      final errorBody = jsonDecode(response.body);
      print("Login gagal: ${errorBody['errors']}");
      return null;
    }
  }

  static Future<List<BudgetModel>> getBudgets(String token) async {
    final url = Uri.parse('${Env.baseUrl}/budgets');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      return budgetModelFromJson(response.body);
    } else {
      throw Exception('Gagal memuat budgets: ${response.body}');
    }
  }

  static Future<void> createBudget({
    required String token,
    required int categoryId,
    required int amount,
    int? assetId,
    String? note,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final url = Uri.parse('${Env.baseUrl}/budgets');
    final body = {
      'id_category': categoryId,
      'amount': amount,
      'first_period': startDate.toIso8601String(),
      'last_period': endDate.toIso8601String(),
    };
    if (assetId != null) {
      body['id_asset'] = assetId;
    }
    if (note != null && note.isNotEmpty) {
      body['note'] = note;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal membuat anggaran: ${response.body}');
    }
  }

  static Future<List<Category>> getCategories(String token) async {
    final url = Uri.parse('${Env.baseUrl}/categories');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body)['data'];
      return jsonList.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat kategori. Status: ${response.statusCode}');
    }
  }

  static Future<List<AssetModel>> getAssets(String token) async {
    final url = Uri.parse('${Env.baseUrl}/assets');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body)['data'];
      return jsonList.map((json) => AssetModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat aset. Status: ${response.statusCode}');
    }
  }

  static Future<SummaryModel> getSummary(String token, DateTime date) async {
    final url = Uri.parse('${Env.baseUrl}/transactions/summary?year=${date.year}&month=${date.month}');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      return summaryModelFromJson(response.body);
    } else {
      throw Exception('Gagal memuat ringkasan: ${response.body}');
    }
  }

  // BARIS BARU: Menambahkan fungsi untuk membuat transaksi
  static Future<String?> createTransaction({
    required String token,
    required int categoryId,
    required int amount,
    int? assetId,
    String? description,
    required DateTime date,
    required String type, // 'income' or 'expense'
  }) async {
    final url = Uri.parse('${Env.baseUrl}/transactions');
    final body = {
      'id_category': categoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String().substring(0, 10), // Hanya kirim tanggal (YYYY-MM-DD)
      'type': type,
    };
    if (assetId != null) {
      body['id_asset'] = assetId;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return null; // Berhasil, tidak ada error message
    } else {
      final errorBody = jsonDecode(response.body);
      return "Error: ${errorBody['errors'] ?? 'Gagal menyimpan transaksi'}";
    }
  }
}