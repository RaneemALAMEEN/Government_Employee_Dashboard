import '../../domain/entities/statistics_employee_entity.dart';
import '../../domain/entities/statistics_process_entity.dart';

enum StatisticsSectionStatus {
  initial,
  loading,
  success,
  empty,
  forbidden,
  failure,
}

abstract class StatisticsState {
  const StatisticsState();
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsLoaded extends StatisticsState {
  final List<StatisticsEmployeeEntity> employees;
  final List<StatisticsProcessEntity> processes;
  final StatisticsSectionStatus employeesStatus;
  final StatisticsSectionStatus transactionsStatus;
  final String? employeesErrorMessage;
  final String? transactionsErrorMessage;
  final String? processFromDate;
  final String? processToDate;

  const StatisticsLoaded({
    required this.employees,
    required this.processes,
    required this.employeesStatus,
    required this.transactionsStatus,
    this.employeesErrorMessage,
    this.transactionsErrorMessage,
    this.processFromDate,
    this.processToDate,
  });
}
