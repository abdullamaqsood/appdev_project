import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReports extends ReportsEvent {
  final DateTime month;
  const LoadReports({required this.month});

  @override
  List<Object?> get props => [month];
}
