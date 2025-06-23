import 'dart:convert';

SummaryModel summaryModelFromJson(String str) => SummaryModel.fromJson(json.decode(str)['data']);

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
        incomeByCategory: List<CategorySummary>.from(json["incomeByCategory"].map((x) => CategorySummary.fromJson(x))),
        expenseByCategory: List<CategorySummary>.from(json["expenseByCategory"].map((x) => CategorySummary.fromJson(x))),
    );
}

class CategorySummary {
    final String categoryName;
    final int totalAmount;

    CategorySummary({
        required this.categoryName,
        required this.totalAmount,
    });
    factory CategorySummary.fromJson(Map<String, dynamic> json) => CategorySummary(
        categoryName: json["categoryName"],
        totalAmount: json["_sum"]["amount"],
    );
}