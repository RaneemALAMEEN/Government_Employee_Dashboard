import '../../domain/entities/statistics_employee_entity.dart';
import '../../domain/entities/statistics_process_entity.dart';

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
  final bool isFallback;
  final String? warningMessage;
  final String? processFromDate;
  final String? processToDate;

  const StatisticsLoaded({
    required this.employees,
    required this.processes,
    this.isFallback = false,
    this.warningMessage,
    this.processFromDate,
    this.processToDate,
  });
}
