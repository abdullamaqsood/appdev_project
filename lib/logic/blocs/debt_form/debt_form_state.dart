import 'package:equatable/equatable.dart';

class DebtFormState extends Equatable {
  final String person;
  final String amount;
  final String note;
  final DateTime givenDate;
  final DateTime dueDate;
  final bool isLoan;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isFailure;

  const DebtFormState({
    required this.person,
    required this.amount,
    required this.note,
    required this.givenDate,
    required this.dueDate,
    required this.isLoan,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.isFailure = false,
  });

  factory DebtFormState.initial() => DebtFormState(
        person: '',
        amount: '',
        note: '',
        givenDate: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 30)),
        isLoan: true,
      );

  DebtFormState copyWith({
    String? person,
    String? amount,
    String? note,
    DateTime? givenDate,
    DateTime? dueDate,
    bool? isLoan,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isFailure,
  }) {
    return DebtFormState(
      person: person ?? this.person,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      givenDate: givenDate ?? this.givenDate,
      dueDate: dueDate ?? this.dueDate,
      isLoan: isLoan ?? this.isLoan,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  List<Object?> get props => [
        person,
        amount,
        note,
        givenDate,
        dueDate,
        isLoan,
        isSubmitting,
        isSuccess,
        isFailure
      ];
}
