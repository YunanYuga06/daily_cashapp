import 'asset_model.dart';
import 'dart:convert';

// Fungsi ini mengubah JSON string menjadi List<BudgetModel>
List<BudgetModel> budgetModelFromJson(String str) =>
    List<BudgetModel>.from(json.decode(str)['data'].map((x) => BudgetModel.fromJson(x)));

// Model untuk Kategori
class Category {
    Category({
        required this.id,
        required this.name,
        required this.type,
    });

    final int id;
    final String name;
    final String type;

    // --- PERBAIKAN UTAMA ADA DI SINI ---
    // Factory ini diubah agar aman dari data null pada 'name' dan 'type'
    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"] ?? 'Tanpa Kategori', // Jika null, gunakan 'Tanpa Kategori'
        type: json["type"] ?? 'General',     // Jika null, gunakan 'General'
    );
}

// Model untuk Anggaran (Budget)
class BudgetModel {
    BudgetModel({
        required this.id,
        required this.amount,
        this.priority,
        required this.spent,
        required this.firstPeriod,
        required this.lastPeriod,
        required this.category,
        required this.asset,
    });

    final int id;
    final int amount;
    final String? priority; // Tetap dibuat nullable (boleh null)
    final int spent;
    final DateTime firstPeriod;
    final DateTime lastPeriod;
    final Category category;
    final AssetModel? asset;

    // Factory ini diubah agar aman dari data null pada 'priority'
    factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        id: json["id"],
        amount: json["amount"] ?? 0,
        priority: json["priority"],
        spent: json["spent"] ?? 0,
        firstPeriod: DateTime.parse(json["first_period"]),
        lastPeriod: DateTime.parse(json["last_period"]),
        category: Category.fromJson(json["category"]),
        asset: json["asset"] == null ? null : AssetModel.fromJson(json["asset"]),
    );
}