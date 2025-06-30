import 'asset_model.dart';
import 'dart:convert';
List<BudgetModel> budgetModelFromJson(String str) =>
    List<BudgetModel>.from(json.decode(str)['data'].map((x) => BudgetModel.fromJson(x)));


class Category {
    Category({
        required this.id,
        required this.name,
        required this.type,
    });

    final int id;
    final String name;
    final String type;

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        type: json["type"],
    );
}


class BudgetModel {
    BudgetModel({
        required this.id,
        required this.amount,
        required this.priority,
        required this.spent,
        required this.firstPeriod,
        required this.lastPeriod,
        required this.category,
        required this.asset,
    });

    final int id;
    final int amount;
    final String priority;
    final int spent;
    final DateTime firstPeriod;
    final DateTime lastPeriod;
    final Category category;
    final AssetModel? asset;

    factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        id: json["id"],
        amount: json["amount"],
        priority: json["priority"],
        spent: json["spent"] ?? 0,
        firstPeriod: DateTime.parse(json["first_period"]),
        lastPeriod: DateTime.parse(json["last_period"]),
        category: Category.fromJson(json["category"]),
        asset: json["asset"] == null ? null : AssetModel.fromJson(json["asset"]),
    );
}