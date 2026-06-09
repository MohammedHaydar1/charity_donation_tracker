class BudgetGoal {
  final int? id;
  final int year;
  final int month;
  final double goalAmount;

  BudgetGoal({
    this.id,
    required this.year,
    required this.month,
    required this.goalAmount,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'year': year,
    'month': month,
    'goalAmount': goalAmount,
  };

  factory BudgetGoal.fromMap(Map<String, dynamic> m) => BudgetGoal(
    id: m['id'],
    year: m['year'],
    month: m['month'],
    goalAmount: m['goalAmount'],
  );
}