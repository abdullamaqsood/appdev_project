class BudgetModel {
  final String id;
  final String category;
  final double limit;
  final DateTime createdAt;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'limit': limit,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      category: map['category'],
      limit: map['limit'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
