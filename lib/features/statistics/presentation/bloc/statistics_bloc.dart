import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/entities/statistics_employee_entity.dart';
import '../../domain/entities/statistics_process_entity.dart';
import '../../domain/usecases/get_department_employees_stats.dart';
import '../../domain/usecases/get_process_definition_stats.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  static const int pageLimit = 10;

  final GetDepartmentEmployeesStats getDepartmentEmployeesStats;
  final GetProcessDefinitionStats getProcessDefinitionStats;
  String? _processFromDate;
  String? _processToDate;
  final Set<String> _employeeRequestedCursors = <String>{};
  final Set<String> _processRequestedCursors = <String>{};
  int _generation = 0;

  StatisticsBloc({
    required this.getDepartmentEmployeesStats,
    required this.getProcessDefinitionStats,
  }) : super(const StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<RefreshStatistics>(_onLoadStatistics);
    on<ApplyProcessDateFilter>(_onApplyProcessDateFilter);
    on<LoadMoreStatisticsEmployees>(_onLoadMoreEmployees);
    on<LoadMoreStatisticsProcesses>(_onLoadMoreProcesses);
    on<RetryStatisticsEmployeesLoadMore>(_onRetryEmployeesLoadMore);
    on<RetryStatisticsProcessesLoadMore>(_onRetryProcessesLoadMore);
  }

  void _onApplyProcessDateFilter(
    ApplyProcessDateFilter event,
    Emitter<StatisticsState> emit,
  ) {
    _processFromDate = event.fromDate;
    _processToDate = event.toDate;
    add(const LoadStatistics());
  }

  Future<void> _onLoadStatistics(
    StatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    final generation = ++_generation;
    _employeeRequestedCursors.clear();
    _processRequestedCursors.clear();
    emit(const StatisticsLoading());

    final departmentIds = _departmentIds();

    final employeesFuture = getDepartmentEmployeesStats(
      departmentIds: departmentIds,
      limit: pageLimit,
    );
    final processesFuture = getProcessDefinitionStats(
      departmentIds: departmentIds,
      limit: pageLimit,
      fromDate: _processFromDate,
      toDate: _processToDate,
    );
    final employeesResult = await employeesFuture;
    final processesResult = await processesFuture;
    if (generation != _generation) return;

    var employees = const <StatisticsEmployeeEntity>[];
    var processes = const <StatisticsProcessEntity>[];
    var employeesStatus = StatisticsSectionStatus.initial;
    var transactionsStatus = StatisticsSectionStatus.initial;
    String? employeesErrorMessage;
    String? transactionsErrorMessage;
    var employeesHasNext = false;
    String? employeesNextCursor;
    var processesHasNext = false;
    String? processesNextCursor;

    employeesResult.fold(
      (failure) {
        employeesStatus = _failureStatus(failure);
        employeesErrorMessage = failure.message;
      },
      (response) {
        employees = response.items;
        employeesNextCursor = response.pagination.nextCursor;
        employeesHasNext =
            response.pagination.hasNext && employeesNextCursor != null;
        employeesStatus = employees.isEmpty
            ? StatisticsSectionStatus.empty
            : StatisticsSectionStatus.success;
      },
    );

    processesResult.fold(
      (failure) {
        transactionsStatus = _failureStatus(failure);
        transactionsErrorMessage = failure.message;
      },
      (response) {
        processes = response.items;
        processesNextCursor = response.pagination.nextCursor;
        processesHasNext =
            response.pagination.hasNext && processesNextCursor != null;
        transactionsStatus = processes.isEmpty
            ? StatisticsSectionStatus.empty
            : StatisticsSectionStatus.success;
      },
    );

    emit(StatisticsLoaded(
      employees: employees,
      processes: processes,
      employeesStatus: employeesStatus,
      transactionsStatus: transactionsStatus,
      employeesErrorMessage: employeesErrorMessage,
      transactionsErrorMessage: transactionsErrorMessage,
      processFromDate: _processFromDate,
      processToDate: _processToDate,
      employeesHasNext: employeesHasNext,
      employeesNextCursor: employeesNextCursor,
      processesHasNext: processesHasNext,
      processesNextCursor: processesNextCursor,
    ));
  }

  Future<void> _onLoadMoreEmployees(
    LoadMoreStatisticsEmployees event,
    Emitter<StatisticsState> emit,
  ) async {
    final current = state;
    if (current is! StatisticsLoaded ||
        current.employeesIsLoadingMore ||
        !current.employeesHasNext) {
      return;
    }
    final cursor = current.employeesNextCursor;
    if (cursor == null ||
        cursor.isEmpty ||
        !_employeeRequestedCursors.add(cursor)) {
      return;
    }
    final generation = _generation;
    emit(current.copyWith(
      employeesIsLoadingMore: true,
      clearEmployeesLoadMoreError: true,
    ));
    final result = await getDepartmentEmployeesStats(
      departmentIds: _departmentIds(),
      limit: pageLimit,
      cursor: cursor,
    );
    if (generation != _generation || state is! StatisticsLoaded) return;
    result.fold(
      (failure) {
        _employeeRequestedCursors.remove(cursor);
        emit((state as StatisticsLoaded).copyWith(
          employeesIsLoadingMore: false,
          employeesLoadMoreError: failure.message,
        ));
      },
      (response) {
        final loaded = state as StatisticsLoaded;
        emit(loaded.copyWith(
          employees: _mergeEmployees(loaded.employees, response.items),
          employeesIsLoadingMore: false,
          employeesHasNext: response.pagination.hasNext &&
              response.pagination.nextCursor != null,
          employeesNextCursor: response.pagination.nextCursor,
          clearEmployeesLoadMoreError: true,
        ));
      },
    );
  }

  Future<void> _onLoadMoreProcesses(
    LoadMoreStatisticsProcesses event,
    Emitter<StatisticsState> emit,
  ) async {
    final current = state;
    if (current is! StatisticsLoaded ||
        current.processesIsLoadingMore ||
        !current.processesHasNext) {
      return;
    }
    final cursor = current.processesNextCursor;
    if (cursor == null ||
        cursor.isEmpty ||
        !_processRequestedCursors.add(cursor)) {
      return;
    }
    final generation = _generation;
    emit(current.copyWith(
      processesIsLoadingMore: true,
      clearProcessesLoadMoreError: true,
    ));
    final result = await getProcessDefinitionStats(
      departmentIds: _departmentIds(),
      limit: pageLimit,
      cursor: cursor,
      fromDate: _processFromDate,
      toDate: _processToDate,
    );
    if (generation != _generation || state is! StatisticsLoaded) return;
    result.fold(
      (failure) {
        _processRequestedCursors.remove(cursor);
        emit((state as StatisticsLoaded).copyWith(
          processesIsLoadingMore: false,
          processesLoadMoreError: failure.message,
        ));
      },
      (response) {
        final loaded = state as StatisticsLoaded;
        emit(loaded.copyWith(
          processes: _mergeProcesses(loaded.processes, response.items),
          processesIsLoadingMore: false,
          processesHasNext: response.pagination.hasNext &&
              response.pagination.nextCursor != null,
          processesNextCursor: response.pagination.nextCursor,
          clearProcessesLoadMoreError: true,
        ));
      },
    );
  }

  void _onRetryEmployeesLoadMore(
    RetryStatisticsEmployeesLoadMore event,
    Emitter<StatisticsState> emit,
  ) {
    add(const LoadMoreStatisticsEmployees());
  }

  void _onRetryProcessesLoadMore(
    RetryStatisticsProcessesLoadMore event,
    Emitter<StatisticsState> emit,
  ) {
    add(const LoadMoreStatisticsProcesses());
  }

  List<int> _departmentIds() {
    final departmentId =
        getIt<SessionService>().activeRoleNotifier.value?.departmentId;
    return departmentId != null ? [departmentId] : <int>[];
  }

  List<StatisticsEmployeeEntity> _mergeEmployees(
    List<StatisticsEmployeeEntity> current,
    List<StatisticsEmployeeEntity> incoming,
  ) {
    final items = <String, StatisticsEmployeeEntity>{
      for (final item in current) item.id: item,
    };
    for (final item in incoming) {
      items[item.id] = item;
    }
    return items.values.toList(growable: false);
  }

  List<StatisticsProcessEntity> _mergeProcesses(
    List<StatisticsProcessEntity> current,
    List<StatisticsProcessEntity> incoming,
  ) {
    final items = <int, StatisticsProcessEntity>{
      for (final item in current) item.processDefinitionId: item,
    };
    for (final item in incoming) {
      items[item.processDefinitionId] = item;
    }
    return items.values.toList(growable: false);
  }

  StatisticsSectionStatus _failureStatus(Failure failure) =>
      failure.statusCode == 403
          ? StatisticsSectionStatus.forbidden
          : StatisticsSectionStatus.failure;
}
