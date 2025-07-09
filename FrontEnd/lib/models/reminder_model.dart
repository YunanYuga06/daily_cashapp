import 'dart:convert';

List<ReminderModel> reminderModelFromJson(String str) =>
    List<ReminderModel>.from(json.decode(str)['data'].map((x) => ReminderModel.fromJson(x)));

class ReminderModel {
    ReminderModel({
        required this.id,
        required this.description,
        required this.amount,
        required this.period,
        required this.date,
    });

    final int id;
    final String description;
    final int amount;
    final String period;
    final DateTime date;

    factory ReminderModel.fromJson(Map<String, dynamic> json) => ReminderModel(
        id: json["id"],
        description: json["description"],
        amount: json["amount"],
        period: json["period"],
        date: DateTime.parse(json["date"]),
    );
}