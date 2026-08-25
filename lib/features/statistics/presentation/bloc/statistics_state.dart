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
  final bool employeesIsLoadingMore;
  final bool employeesHasNext;
  final String? employeesNextCursor;
  final String? employeesLoadMoreError;
  final bool processesIsLoadingMore;
  final bool processesHasNext;
  final String? processesNextCursor;
  final String? processesLoadMoreError;

  const StatisticsLoaded({
    required this.employees,
    required this.processes,
    required this.employeesStatus,
    required this.transactionsStatus,
    this.employeesErrorMessage,
    this.transactionsErrorMessage,
    this.processFromDate,
    this.processToDate,
    this.employeesIsLoadingMore = false,
    this.employeesHasNext = false,
    this.employeesNextCursor,
    this.employeesLoadMoreError,
    this.processesIsLoadingMore = false,
    this.processesHasNext = false,
    this.processesNextCursor,
    this.processesLoadMoreError,
  });

  StatisticsLoaded copyWith({
    List<StatisticsEmployeeEntity>? employees,
    List<StatisticsProcessEntity>? processes,
    StatisticsSectionStatus? employeesStatus,
    StatisticsSectionStatus? transactionsStatus,
    String? employeesErrorMessage,
    String? transactionsErrorMessage,
    String? processFromDate,
    String? processToDate,
    bool? employeesIsLoadingMore,
    bool? employeesHasNext,
    String? employeesNextCursor,
    String? employeesLoadMoreError,
    bool? processesIsLoadingMore,
    bool? processesHasNext,
    String? processesNextCursor,
    String? processesLoadMoreError,
    bool clearEmployeesLoadMoreError = false,
    bool clearProcessesLoadMoreError = false,
  }) =>
      StatisticsLoaded(
        employees: employees ?? this.employees,
        processes: processes ?? this.processes,
        employeesStatus: employeesStatus ?? this.employeesStatus,
        transactionsStatus: transactionsStatus ?? this.transactionsStatus,
        employeesErrorMessage:
            employeesErrorMessage ?? this.employeesErrorMessage,
        transactionsErrorMessage:
            transactionsErrorMessage ?? this.transactionsErrorMessage,
        processFromDate: processFromDate ?? this.processFromDate,
        processToDate: processToDate ?? this.processToDate,
        employeesIsLoadingMore:
            employeesIsLoadingMore ?? this.employeesIsLoadingMore,
        employeesHasNext: employeesHasNext ?? this.employeesHasNext,
        employeesNextCursor: employeesNextCursor ?? this.employeesNextCursor,
        employeesLoadMoreError: clearEmployeesLoadMoreError
            ? null
            : employeesLoadMoreError ?? this.employeesLoadMoreError,
        processesIsLoadingMore:
            processesIsLoadingMore ?? this.processesIsLoadingMore,
        processesHasNext: processesHasNext ?? this.processesHasNext,
        processesNextCursor: processesNextCursor ?? this.processesNextCursor,
        processesLoadMoreError: clearProcessesLoadMoreError
            ? null
            : processesLoadMoreError ?? this.processesLoadMoreError,
      );
}
