class IncomeModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String note;

  IncomeModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}
