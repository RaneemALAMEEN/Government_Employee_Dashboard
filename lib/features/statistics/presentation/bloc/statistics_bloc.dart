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
  final GetDepartmentEmployeesStats getDepartmentEmployeesStats;
  final GetProcessDefinitionStats getProcessDefinitionStats;
  String? _processFromDate;
  String? _processToDate;

  StatisticsBloc({
    required this.getDepartmentEmployeesStats,
    required this.getProcessDefinitionStats,
  }) : super(const StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<RefreshStatistics>(_onLoadStatistics);
    on<ApplyProcessDateFilter>(_onApplyProcessDateFilter);
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
    emit(const StatisticsLoading());

    final departmentId =
        getIt<SessionService>().activeRoleNotifier.value?.departmentId;
    final departmentIds = departmentId != null ? [departmentId] : <int>[];

    final employeesFuture =
        getDepartmentEmployeesStats(departmentIds: departmentIds);
    final processesFuture = getProcessDefinitionStats(
      departmentIds: departmentIds,
      fromDate: _processFromDate,
      toDate: _processToDate,
    );
    final employeesResult = await employeesFuture;
    final processesResult = await processesFuture;

    var employees = const <StatisticsEmployeeEntity>[];
    var processes = const <StatisticsProcessEntity>[];
    var employeesStatus = StatisticsSectionStatus.initial;
    var transactionsStatus = StatisticsSectionStatus.initial;
    String? employeesErrorMessage;
    String? transactionsErrorMessage;

    employeesResult.fold(
      (failure) {
        employeesStatus = _failureStatus(failure);
        employeesErrorMessage = failure.message;
      },
      (items) {
        employees = items;
        employeesStatus = items.isEmpty
            ? StatisticsSectionStatus.empty
            : StatisticsSectionStatus.success;
      },
    );

    processesResult.fold(
      (failure) {
        transactionsStatus = _failureStatus(failure);
        transactionsErrorMessage = failure.message;
      },
      (items) {
        processes = items;
        transactionsStatus = items.isEmpty
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
    ));
  }

  StatisticsSectionStatus _failureStatus(Failure failure) =>
      failure.statusCode == 403
          ? StatisticsSectionStatus.forbidden
          : StatisticsSectionStatus.failure;
}
