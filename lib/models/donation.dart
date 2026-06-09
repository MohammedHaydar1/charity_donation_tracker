class Donation {
  final int? id;
  final int charityId;
  final String charityName;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final bool isRecurring;
  final String? recurringInterval;
  final String paymentMethod;

  Donation({
    this.id,
    required this.charityId,
    required this.charityName,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.isRecurring = false,
    this.recurringInterval,
    this.paymentMethod = 'Cash',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'charityId': charityId,
    'charityName': charityName,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'note': note,
    'isRecurring': isRecurring ? 1 : 0,
    'recurringInterval': recurringInterval,
    'paymentMethod': paymentMethod,
  };

  factory Donation.fromMap(Map<String, dynamic> m) => Donation(
    id: m['id'],
    charityId: m['charityId'],
    charityName: m['charityName'],
    amount: m['amount'],
    category: m['category'],
    date: DateTime.parse(m['date']),
    note: m['note'],
    isRecurring: m['isRecurring'] == 1,
    recurringInterval: m['recurringInterval'],
    paymentMethod: m['paymentMethod'] ?? 'Cash',
  );
}