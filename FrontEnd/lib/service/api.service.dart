// daily_cashapp/FrontEnd/lib/service/api.service.dart

import 'dart:convert';
import 'dart:io';

import 'package:daily_cashapp/config/env.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/asset_model.dart';
import '../models/budget.dart';
import '../models/profile_model.dart';
import '../models/reminder_model.dart';
import '../models/transaksi_model.dart';
import '../models/user.model.dart';

// Model Sederhana untuk Data Transaksi yang Akan Dikirim
class TransactionData {
  final int categoryId;
  final int amount;
  final String type;
  final DateTime date;
  final int? assetId;
  final String? description;

  TransactionData({
    required this.categoryId,
    required this.amount,
    required this.type,
    required this.date,
    this.assetId,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id_category': categoryId,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String().substring(0, 10), // Format YYYY-MM-DD
    };
    if (assetId != null) {
      data['id_asset'] = assetId;
    }
    if (description != null && description!.isNotEmpty) {
      data['description'] = description;
    }
    return data;
  }
}

class ApiService {
  static Future<String?> registerUser(UserModel user) async {
    final url = Uri.parse('${Env.baseUrl}/users');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
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
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
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

  // --- FUNGSI TRANSAKSI ---
  static Future<void> createTransaction(
      String token, TransactionData transaction) async {
    final url = Uri.parse('${Env.baseUrl}/transactions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(transaction.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menyimpan transaksi: ${response.body}');
    }
  }

  static Future<List<TransactionModel>> getTransactions(
    String token, {
    int? year,
    int? month,
  }) async {
    var uri = Uri.parse('${Env.baseUrl}/transactions');
    final Map<String, String> queryParams = {};
    if (year != null) {
      queryParams['year'] = year.toString();
    }
    if (month != null) {
      queryParams['month'] = month.toString();
    }
    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      // Perhatikan di sini, mungkin Anda perlu membuat `transactionModelFromJson`
      // Untuk saat ini, asumsikan model dan fungsinya sudah ada
      // return transactionModelFromJson(response.body);
      throw UnimplementedError(
          "Fungsi transactionModelFromJson belum diimplementasikan.");
    } else {
      throw Exception('Gagal memuat transaksi: ${response.body}');
    }
  }

  // --- FUNGSI ASET ---
  static Future<void> createAsset({
    required String token,
    required String assetName,
    required String assetType,
    required int initialAmount,
  }) async {
    final url = Uri.parse('${Env.baseUrl}/assets');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'asset_name': assetName,
        'asset_type': assetType,
        'first_amount': initialAmount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal membuat aset: ${response.body}');
    }
  }

  static Future<List<AssetModel>> getAssets(String token) async {
    final url = Uri.parse('${Env.baseUrl}/assets');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body)['data'];
      return jsonList.map((json) => AssetModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat aset. Status: ${response.statusCode}');
    }
  }

  // --- FUNGSI BUDGET ---
  static Future<List<BudgetModel>> getBudgets(
    String token,
    DateTime date,
  ) async {
    final url = Uri.parse(
      '${Env.baseUrl}/budgets?year=${date.year}&month=${date.month}',
    );
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

  static Future<void> updateBudget({
    required String token,
    required int budgetId,
    required int categoryId,
    required int amount,
    int? assetId,
    String? note,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final url = Uri.parse('${Env.baseUrl}/budgets/$budgetId');
    final body = {
      'id_category': categoryId,
      'amount': amount,
      'first_period': startDate.toIso8601String(),
      'last_period': endDate.toIso8601String(),
      'id_asset': assetId,
      'note': note,
    };
    body.removeWhere((key, value) => value == null);
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui anggaran: ${response.body}');
    }
  }

  static Future<void> deleteBudget(String token, int budgetId) async {
    final url = Uri.parse('${Env.baseUrl}/budgets/$budgetId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus anggaran: ${response.body}');
    }
  }

  // --- FUNGSI KATEGORI ---
  static Future<List<Category>> getCategories(String token) async {
    final url = Uri.parse('${Env.baseUrl}/categories');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body)['data'];
      return jsonList.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat kategori. Status: ${response.statusCode}');
    }
  }

  // --- FUNGSI SUMMARY & PROFIL ---
  static Future<SummaryModel> getSummary(String token, DateTime date) async {
    final url = Uri.parse(
        '${Env.baseUrl}/transactions/summary?year=${date.year}&month=${date.month}');
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

  static Future<ProfileModel> getCurrentUser(String token) async {
    final url = Uri.parse('${Env.baseUrl}/users/current');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );
    if (response.statusCode == 200) {
      return profileModelFromJson(response.body);
    } else {
      throw Exception('Gagal memuat data user: ${response.body}');
    }
  }

  static Future<bool> updateUserProfile({
    required String token,
    required String name,
    File? imageFile,
  }) async {
    final url = Uri.parse('${Env.baseUrl}/users/current');
    var request = http.MultipartRequest('PUT', url);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning': 'true',
    });
    request.fields['name'] = name;
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_picture',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }
    final response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      final respStr = await response.stream.bytesToString();
      print('Gagal update: $respStr');
      return false;
    }
  }
  
  // --- FUNGSI REMINDER ---
  static Future<void> createReminder({
    required String token,
    required String description,
    required int amount,
    required String period,
    required DateTime date,
  }) async {
    final url = Uri.parse('${Env.baseUrl}/reminders');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'description': description,
        'amount': amount,
        'period': period,
        'date': date.toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal membuat pengingat: ${response.body}');
    }
  }

  static Future<List<ReminderModel>> getReminders(
    String token,
    DateTime date,
  ) async {
    final url = Uri.parse(
      '${Env.baseUrl}/reminders?year=${date.year}&month=${date.month}',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      return reminderModelFromJson(response.body);
    } else {
      throw Exception('Gagal memuat pengingat: ${response.body}');
    }
  }
}