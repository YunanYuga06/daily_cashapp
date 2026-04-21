import 'dart:convert';

import 'package:daily_cashapp/models/asset_model.dart';
import 'package:daily_cashapp/models/budget.dart';

SummaryModel summaryModelFromJson(String str) =>
    SummaryModel.fromJson(json.decode(str)['data']);

class SummaryModel {
  final int totalIncome;
  final int totalExpense;
  final int totalNet;
  final List<CategorySummary> incomeByCategory;
  final List<CategorySummary> expenseByCategory;

  SummaryModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.totalNet,
    required this.incomeByCategory,
    required this.expenseByCategory,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) => SummaryModel(
    totalIncome: json["totalIncome"],
    totalExpense: json["totalExpense"],
    totalNet: json["totalNet"],
    incomeByCategory: List<CategorySummary>.from(
      json["incomeByCategory"].map((x) => CategorySummary.fromJson(x)),
    ),
    expenseByCategory: List<CategorySummary>.from(
      json["expenseByCategory"].map((x) => CategorySummary.fromJson(x)),
    ),
  );
}

class CategorySummary {
  final String categoryName;
  final int totalAmount;

  CategorySummary({required this.categoryName, required this.totalAmount});
  factory CategorySummary.fromJson(Map<String, dynamic> json) =>
      CategorySummary(
        categoryName: json["categoryName"],
        totalAmount: json["_sum"]["amount"],
      );
}

List<TransactionModel> transactionModelFromJson(String str) =>
    List<TransactionModel>.from(
      json.decode(str)['data'].map((x) => TransactionModel.fromJson(x)),
    );

// Model untuk merepresentasikan satu data transaksi
class TransactionModel {
  final int id;
  final int amount;
  final String type; // 'income' atau 'expense'
  final String? description;
  final DateTime date;
  final Category category; // Menggunakan model Category yang sudah ada
  final AssetModel?
  asset; // Menggunakan model AssetModel yang sudah ada (opsional)

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    this.description,
    required this.date,
    required this.category,
    this.asset,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Fungsi pintar pelindung tipe data (Otomatis mengubah String menjadi Int)
    int parseIntSafe(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return TransactionModel(
      // Menggunakan parseIntSafe untuk semua data angka (ID dan Amount)
      id: parseIntSafe(json["id"]),
      amount: parseIntSafe(json["amount"]),
      
      type: json["type"]?.toString() ?? 'expense',
      description: json["description"]?.toString(),
      
      // Parsing tanggal dengan aman
      date: json["date"] != null 
          ? DateTime.tryParse(json["date"].toString()) ?? DateTime.now() 
          : DateTime.now(),
      
      // Jika Anda menggunakan nested object (kategori dan aset)
      category: json["category"] != null 
          ? Category.fromJson(json["category"]) 
          : Category(id: 0, name: 'Lainnya', type: ''),
          
      asset: json["asset"] != null 
          ? AssetModel.fromJson(json["asset"]) 
          : null,
    );
  }
}
