class Budget {
  final String category;
  final double total;
  final double spent;
  final double dailyLimit;

  Budget({
    required this.category,
    required this.total,
    this.spent = 0,
    required this.dailyLimit,
  });
}
