// daily_cashapp/FrontEnd/lib/models/budget.dart

import 'asset_model.dart';
import 'dart:convert';

List<BudgetModel> budgetModelFromJson(String str) =>
    List<BudgetModel>.from(json.decode(str)['data'].map((x) => BudgetModel.fromJson(x)));


class Category {
    Category({
        required this.id,
        required this.name,
        required this.type, // PERUBAHAN PENTING: Tambahkan 'type' di konstruktor
    });

    final int id;
    final String name;
    final String type; // PERUBAHAN PENTING: Deklarasikan properti 'type' di sini

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        type: json["type"], // PERUBAHAN PENTING: Ambil nilai 'type' dari JSON
    );
}


class BudgetModel {
    BudgetModel({
        required this.id,
        required this.amount,
        required this.firstPeriod,
        required this.lastPeriod,
        required this.category,
        required this.asset,
    });

    final int id;
    final int amount;
    final DateTime firstPeriod;
    final DateTime lastPeriod;
    final Category category;
    final AssetModel? asset;

    factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        id: json["id"],
        amount: json["amount"],
        firstPeriod: DateTime.parse(json["first_period"]),
        lastPeriod: DateTime.parse(json["last_period"]),
        category: Category.fromJson(json["category"]),
        asset: json["asset"] == null ? null : AssetModel.fromJson(json["asset"]),
    );
}