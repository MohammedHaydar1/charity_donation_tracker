class Charity {
  final int? id;
  final String name;
  final String category;
  final String? description;
  final String? website;
  final int colorValue;
  final DateTime createdAt;

  Charity({
    this.id,
    required this.name,
    required this.category,
    this.description,
    this.website,
    required this.colorValue,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'description': description,
    'website': website,
    'colorValue': colorValue,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Charity.fromMap(Map<String, dynamic> m) => Charity(
    id: m['id'],
    name: m['name'],
    category: m['category'],
    description: m['description'],
    website: m['website'],
    colorValue: m['colorValue'],
    createdAt: DateTime.parse(m['createdAt']),
  );
}