import 'package:equatable/equatable.dart';

class IncomeFormState extends Equatable {
  final String title;
  final String amount;
  final String note;
  final DateTime date;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  const IncomeFormState({
    required this.title,
    required this.amount,
    required this.note,
    required this.date,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
  });

  factory IncomeFormState.initial() => IncomeFormState(
        title: '',
        amount: '',
        note: '',
        date: DateTime.now(),
      );

  IncomeFormState copyWith({
    String? title,
    String? amount,
    String? note,
    DateTime? date,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
  }) {
    return IncomeFormState(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  List<Object?> get props =>
      [title, amount, note, date, isSubmitting, isSuccess, isFailure];
}
