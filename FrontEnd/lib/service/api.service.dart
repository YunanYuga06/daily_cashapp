import 'dart:convert';
import 'package:daily_cashapp/config/env.dart';
import 'package:http/http.dart' as http;
import '../models/user.model.dart';
import '../models/asset_model.dart';
import '../models/budget.dart';
import '../models/transaksi_model.dart';
import '../models/profile_model.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

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

  static Future<List<BudgetModel>> getBudgets(String token, DateTime date) async {
    final url = Uri.parse('${Env.baseUrl}/budgets?year=${date.year}&month=${date.month}');

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
}