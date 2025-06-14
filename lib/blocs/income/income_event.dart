import '../../data/models/income_model.dart';

abstract class IncomeEvent {}

class AddIncomeEvent extends IncomeEvent {
  final IncomeModel income;
  AddIncomeEvent(this.income);
}
