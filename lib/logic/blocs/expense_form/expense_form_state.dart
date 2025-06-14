import 'package:equatable/equatable.dart';

class ExpenseFormState extends Equatable {
  final String title;
  final String amount;
  final String note;
  final DateTime date;
  final String category;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  const ExpenseFormState({
    required this.title,
    required this.amount,
    required this.note,
    required this.date,
    required this.category,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
  });

  factory ExpenseFormState.initial() => ExpenseFormState(
        title: '',
        amount: '',
        note: '',
        date: DateTime.now(),
        category: 'Food',
      );

  ExpenseFormState copyWith({
    String? title,
    String? amount,
    String? note,
    DateTime? date,
    String? category,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
  }) {
    return ExpenseFormState(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      category: category ?? this.category,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  List<Object?> get props =>
      [title, amount, note, date, category, isSubmitting, isSuccess, isFailure];
}
