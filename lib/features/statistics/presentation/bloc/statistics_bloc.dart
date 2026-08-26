import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/entities/statistics_employee_entity.dart';
import '../../domain/entities/statistics_pagination_entity.dart';
import '../../domain/entities/statistics_process_entity.dart';
import '../../domain/usecases/get_department_employees_stats.dart';
import '../../domain/usecases/get_process_definition_stats.dart';
import '../../domain/usecases/search_employees_usecase.dart';
import '../../domain/usecases/search_process_definitions_usecase.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetDepartmentEmployeesStats getDepartmentEmployeesStats;
  final GetProcessDefinitionStats getProcessDefinitionStats;
  final SearchEmployeesUseCase searchEmployeesUseCase;
  final SearchProcessDefinitionsUseCase searchProcessDefinitionsUseCase;
  String? _processFromDate;
  String? _processToDate;

  static const int _pageLimit = 6;

  StatisticsBloc({
    required this.getDepartmentEmployeesStats,
    required this.getProcessDefinitionStats,
    required this.searchEmployeesUseCase,
    required this.searchProcessDefinitionsUseCase,
  }) : super(const StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<RefreshStatistics>(_onLoadStatistics);
    on<LoadMoreStatisticsEmployees>(_onLoadMoreStatisticsEmployees);
    on<RetryStatisticsEmployeesLoadMore>(_onLoadMoreStatisticsEmployees);
    on<LoadMoreStatisticsProcesses>(_onLoadMoreStatisticsProcesses);
    on<RetryStatisticsProcessesLoadMore>(_onLoadMoreStatisticsProcesses);
    on<ApplyProcessDateFilter>(_onApplyProcessDateFilter);
    on<SearchEmployeesEvent>(_onSearchEmployees);
    on<LoadMoreSearchEmployeesEvent>(_onLoadMoreSearchEmployees);
    on<ClearEmployeeSearchEvent>(_onClearEmployeeSearch);
    on<SearchProcessesEvent>(_onSearchProcesses);
    on<LoadMoreSearchProcessesEvent>(_onLoadMoreSearchProcesses);
    on<ClearProcessSearchEvent>(_onClearProcessSearch);
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

    final employeesFuture = getDepartmentEmployeesStats(
      departmentIds: departmentIds,
      limit: _pageLimit,
    );
    final processesFuture = getProcessDefinitionStats(
      departmentIds: departmentIds,
      limit: _pageLimit,
      fromDate: _processFromDate,
      toDate: _processToDate,
    );
    final employeesResult = await employeesFuture;
    final processesResult = await processesFuture;

    var employees = const <StatisticsEmployeeEntity>[];
    StatisticsPaginationEntity? employeesPagination;
    var processes = const <StatisticsProcessEntity>[];
    StatisticsPaginationEntity? processesPagination;
    var employeesStatus = StatisticsSectionStatus.initial;
    var transactionsStatus = StatisticsSectionStatus.initial;
    String? employeesErrorMessage;
    String? transactionsErrorMessage;

    employeesResult.fold(
      (failure) {
        employeesStatus = _failureStatus(failure);
        employeesErrorMessage = failure.message;
      },
      (paginated) {
        employees = paginated.items;
        employeesPagination = paginated.pagination;
        employeesStatus = paginated.items.isEmpty
            ? StatisticsSectionStatus.empty
            : StatisticsSectionStatus.success;
      },
    );

    processesResult.fold(
      (failure) {
        transactionsStatus = _failureStatus(failure);
        transactionsErrorMessage = failure.message;
      },
      (paginated) {
        processes = paginated.items;
        processesPagination = paginated.pagination;
        transactionsStatus = paginated.items.isEmpty
            ? StatisticsSectionStatus.empty
            : StatisticsSectionStatus.success;
      },
    );

    emit(StatisticsLoaded(
      employees: employees,
      employeesPagination: employeesPagination,
      processes: processes,
      processesPagination: processesPagination,
      employeesStatus: employeesStatus,
      transactionsStatus: transactionsStatus,
      employeesErrorMessage: employeesErrorMessage,
      transactionsErrorMessage: transactionsErrorMessage,
      processFromDate: _processFromDate,
      processToDate: _processToDate,
    ));
  }

  Future<void> _onLoadMoreStatisticsEmployees(
    StatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state is! StatisticsLoaded) return;
    final currentState = state as StatisticsLoaded;

    if (currentState.isLoadingMoreEmployees) return;

    final pagination = currentState.employeesPagination;
    if (pagination == null ||
        !pagination.hasNext ||
        pagination.nextCursor == null) {
      return;
    }

    emit(currentState.copyWith(
      isLoadingMoreEmployees: true,
      clearEmployeesLoadMoreError: true,
    ));

    final departmentId =
        getIt<SessionService>().activeRoleNotifier.value?.departmentId;
    final departmentIds = departmentId != null ? [departmentId] : <int>[];

    final result = await getDepartmentEmployeesStats(
      departmentIds: departmentIds,
      limit: _pageLimit,
      cursor: pagination.nextCursor,
    );

    if (state is! StatisticsLoaded) return;
    final updatedCurrentState = state as StatisticsLoaded;

    result.fold(
      (failure) {
        emit(updatedCurrentState.copyWith(
          isLoadingMoreEmployees: false,
          employeesLoadMoreErrorMessage: failure.message,
        ));
      },
      (paginated) {
        emit(updatedCurrentState.copyWith(
          isLoadingMoreEmployees: false,
          employees: [
            ...updatedCurrentState.employees,
            ...paginated.items,
          ],
          employeesPagination: paginated.pagination,
          clearEmployeesLoadMoreError: true,
        ));
      },
    );
  }

  Future<void> _onLoadMoreStatisticsProcesses(
    StatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state is! StatisticsLoaded) return;
    final currentState = state as StatisticsLoaded;

    if (currentState.isLoadingMoreProcesses) return;

    final pagination = currentState.processesPagination;
    if (pagination == null ||
        !pagination.hasNext ||
        pagination.nextCursor == null) {
      return;
    }

    emit(currentState.copyWith(
      isLoadingMoreProcesses: true,
      clearProcessesLoadMoreError: true,
    ));

    final departmentId =
        getIt<SessionService>().activeRoleNotifier.value?.departmentId;
    final departmentIds = departmentId != null ? [departmentId] : <int>[];

    final result = await getProcessDefinitionStats(
      departmentIds: departmentIds,
      limit: _pageLimit,
      cursor: pagination.nextCursor,
      fromDate: _processFromDate,
      toDate: _processToDate,
    );

    if (state is! StatisticsLoaded) return;
    final updatedCurrentState = state as StatisticsLoaded;

    result.fold(
      (failure) {
        emit(updatedCurrentState.copyWith(
          isLoadingMoreProcesses: false,
          processesLoadMoreErrorMessage: failure.message,
        ));
      },
      (paginated) {
        emit(updatedCurrentState.copyWith(
          isLoadingMoreProcesses: false,
          processes: [
            ...updatedCurrentState.processes,
            ...paginated.items,
          ],
          processesPagination: paginated.pagination,
          clearProcessesLoadMoreError: true,
        ));
      },
    );
  }

  Future<void> _onSearchEmployees(
    SearchEmployeesEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state is! StatisticsLoaded) return;
    final currentState = state as StatisticsLoaded;

    final trimmed = event.query.trim();
    if (trimmed.isEmpty) {
      emit(currentState.copyWith(
        searchQuery: '',
        searchResults: [],
        isSearching: false,
        clearSearchError: true,
        clearPagination: true,
      ));
      return;
    }

    emit(currentState.copyWith(
      searchQuery: trimmed,
      isSearching: true,
      clearSearchError: true,
    ));

    final result = await searchEmployeesUseCase(
      query: trimmed,
      limit: _pageLimit,
    );

    if (state is! StatisticsLoaded) return;
    final updatedCurrentState = state as StatisticsLoaded;

    // Check if query hasn't changed while request was in flight
    if (updatedCurrentState.searchQuery != trimmed) return;

    result.fold(
      (failure) {
        emit(updatedCurrentState.copyWith(
          isSearching: false,
          searchErrorMessage: failure.message,
        ));
      },
      (searchResult) {
        emit(updatedCurrentState.copyWith(
          isSearching: false,
          searchResults: searchResult.items,
          searchPagination: searchResult.pagination,
          clearSearchError: true,
        ));
      },
    );
  }

  Future<void> _onLoadMoreSearchEmployees(
    LoadMoreSearchEmployeesEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state is! StatisticsLoaded) return;
    final currentState = state as StatisticsLoaded;

    if (!currentState.isSearchActive ||
        currentState.isLoadingMoreSearch ||
        currentState.isSearching) {
      return;
    }

    final pagination = currentState.searchPagination;
    if (pagination == null ||
        !pagination.hasNext ||
        pagination.nextCursor == null) {
      return;
    }

    emit(currentState.copyWith(isLoadingMoreSearch: true));

    final result = await searchEmployeesUseCase(
      query: currentState.searchQuery,
      cursor: pagination.nextCursor,
      limit: _pageLimit,
    );

    if (state is! StatisticsLoaded) return;
    final updatedCurrentState = state as StatisticsLoaded;

    result.fold(
      (failure) {
        emit(updatedCurrentState.copyWith(
          isLoadingMoreSearch: false,
          searchErrorMessage: failure.message,
        ));
      },
      (searchResult) {
        emit(updatedCurrentState.copyWith(
          isLoadingMoreSearch: false,
          searchResults: [
            ...updatedCurrentState.searchResults,
            ...searchResult.items,
          ],
          searchPagination: searchResult.pagination,
        ));
      },
    );
  }

  void _onClearEmployeeSearch(
    ClearEmployeeSearchEvent event,
    Emitter<StatisticsState> emit,
  ) {
    if (state is! StatisticsLoaded) return;
    final currentState = state as StatisticsLoaded;
    emit(currentState.copyWith(
      searchQuery: '',
      searchResults: [],
      isSearching: false,
      isLoadingMoreSearch: false,
      clearSearchError: true,
      clearPagination: true,
    ));
  }

  Future<void> _onSearchProcesses(
    SearchProcessesEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state is! StatisticsLoaded) return;
    final currentState = state as StatisticsLoaded;

    final trimmed = event.query.trim();
    if (trimmed.isEmpty) {
      emit(currentState.copyWith(
        processSearchQuery: '',
        processSearchResults: [],
        isSearchingProcesses: false,
        clearProcessSearchError: true,
        clearProcessPagination: true,
      ));
      return;
    }

    emit(currentState.copyWith(
      processSearchQuery: trimmed,
      isSearchingProcesses: true,
      clearProcessSearchError: true,
    ));

    final sessionService = getIt<SessionService>();
    final orgId = await sessionService.resolveOrganizationId();

    final result = await searchProcessDefinitionsUseCase(
      organizationId: orgId > 0 ? orgId : 1,
      query: trimmed,
      limit: _pageLimit,
    );

    if (state is! StatisticsLoaded) return;
    final updatedCurrentState = state as StatisticsLoaded;

    if (updatedCurrentState.processSearchQuery != trimmed) return;

    result.fold(
      (failure) {
        emit(updatedCurrentState.copyWith(
          isSearchingProcesses: false,
          processSearchErrorMessage: failure.message,
        ));
      },
      (searchResult) {
        emit(updatedCurrentState.copyWith(
          isSearchingProcesses: false,
          processSearchResults: searchResult.items,
          processSearchPagination: searchResult.pagination,
          clearProcessSearchError: true,
        ));
      },
    );
  }

  Future<void> _onLoadMoreSearchProcesses(
    LoadMoreSearchProcessesEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state is! StatisticsLoaded) return;
    final currentState = state as StatisticsLoaded;

    if (!currentState.isProcessSearchActive ||
        currentState.isLoadingMoreProcessSearch ||
        currentState.isSearchingProcesses) {
      return;
    }

    final pagination = currentState.processSearchPagination;
    if (pagination == null ||
        !pagination.hasNext ||
        pagination.nextCursor == null) {
      return;
    }

    emit(currentState.copyWith(isLoadingMoreProcessSearch: true));

    final sessionService = getIt<SessionService>();
    final orgId = await sessionService.resolveOrganizationId();

    final result = await searchProcessDefinitionsUseCase(
      organizationId: orgId > 0 ? orgId : 1,
      query: currentState.processSearchQuery,
      cursor: pagination.nextCursor,
      limit: _pageLimit,
    );

    if (state is! StatisticsLoaded) return;
    final updatedCurrentState = state as StatisticsLoaded;

    result.fold(
      (failure) {
        emit(updatedCurrentState.copyWith(
          isLoadingMoreProcessSearch: false,
          processSearchErrorMessage: failure.message,
        ));
      },
      (searchResult) {
        emit(updatedCurrentState.copyWith(
          isLoadingMoreProcessSearch: false,
          processSearchResults: [
            ...updatedCurrentState.processSearchResults,
            ...searchResult.items,
          ],
          processSearchPagination: searchResult.pagination,
        ));
      },
    );
  }

  void _onClearProcessSearch(
    ClearProcessSearchEvent event,
    Emitter<StatisticsState> emit,
  ) {
    if (state is! StatisticsLoaded) return;
    final currentState = state as StatisticsLoaded;
    emit(currentState.copyWith(
      processSearchQuery: '',
      processSearchResults: [],
      isSearchingProcesses: false,
      isLoadingMoreProcessSearch: false,
      clearProcessSearchError: true,
      clearProcessPagination: true,
    ));
  }

  StatisticsSectionStatus _failureStatus(Failure failure) =>
      failure.statusCode == 403
          ? StatisticsSectionStatus.forbidden
          : StatisticsSectionStatus.failure;
}
