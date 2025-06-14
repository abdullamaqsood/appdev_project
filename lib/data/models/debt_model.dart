class DebtModel {
  final String id;
  final String person;
  final double amount;
  final DateTime givenDate;
  final DateTime dueDate;
  final String note;
  final bool isLoan; // true = Loan (you gave), false = Debt (you borrowed)

  DebtModel({
    required this.id,
    required this.person,
    required this.amount,
    required this.givenDate,
    required this.dueDate,
    required this.note,
    required this.isLoan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person': person,
      'amount': amount,
      'givenDate': givenDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'note': note,
      'isLoan': isLoan,
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'],
      person: map['person'],
      amount: map['amount'],
      givenDate: DateTime.parse(map['givenDate']),
      dueDate: DateTime.parse(map['dueDate']),
      note: map['note'],
      isLoan: map['isLoan'],
    );
  }
}
