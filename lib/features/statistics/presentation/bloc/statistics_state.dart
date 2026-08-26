import '../../domain/entities/employee_search_result_entity.dart';
import '../../domain/entities/process_search_result_entity.dart';
import '../../domain/entities/statistics_employee_entity.dart';
import '../../domain/entities/statistics_pagination_entity.dart';
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

  // Employee Pagination State
  final StatisticsPaginationEntity? employeesPagination;
  final bool isLoadingMoreEmployees;
  final String? employeesLoadMoreErrorMessage;

  // Process / Transaction Pagination State
  final StatisticsPaginationEntity? processesPagination;
  final bool isLoadingMoreProcesses;
  final String? processesLoadMoreErrorMessage;

  // Employee Search State
  final String searchQuery;
  final bool isSearching;
  final bool isLoadingMoreSearch;
  final List<EmployeeSearchItemEntity> searchResults;
  final EmployeeSearchPaginationEntity? searchPagination;
  final String? searchErrorMessage;

  // Process / Transaction Search State
  final String processSearchQuery;
  final bool isSearchingProcesses;
  final bool isLoadingMoreProcessSearch;
  final List<ProcessSearchItemEntity> processSearchResults;
  final ProcessSearchPaginationEntity? processSearchPagination;
  final String? processSearchErrorMessage;

  const StatisticsLoaded({
    required this.employees,
    required this.processes,
    required this.employeesStatus,
    required this.transactionsStatus,
    this.employeesErrorMessage,
    this.transactionsErrorMessage,
    this.processFromDate,
    this.processToDate,
    this.employeesPagination,
    this.isLoadingMoreEmployees = false,
    this.employeesLoadMoreErrorMessage,
    this.processesPagination,
    this.isLoadingMoreProcesses = false,
    this.processesLoadMoreErrorMessage,
    this.searchQuery = '',
    this.isSearching = false,
    this.isLoadingMoreSearch = false,
    this.searchResults = const [],
    this.searchPagination,
    this.searchErrorMessage,
    this.processSearchQuery = '',
    this.isSearchingProcesses = false,
    this.isLoadingMoreProcessSearch = false,
    this.processSearchResults = const [],
    this.processSearchPagination,
    this.processSearchErrorMessage,
  });

  bool get isSearchActive => searchQuery.trim().isNotEmpty;
  bool get isProcessSearchActive => processSearchQuery.trim().isNotEmpty;

  StatisticsLoaded copyWith({
    List<StatisticsEmployeeEntity>? employees,
    List<StatisticsProcessEntity>? processes,
    StatisticsSectionStatus? employeesStatus,
    StatisticsSectionStatus? transactionsStatus,
    String? employeesErrorMessage,
    String? transactionsErrorMessage,
    String? processFromDate,
    String? processToDate,
    StatisticsPaginationEntity? employeesPagination,
    bool? isLoadingMoreEmployees,
    String? employeesLoadMoreErrorMessage,
    bool clearEmployeesLoadMoreError = false,
    bool clearEmployeesPagination = false,
    StatisticsPaginationEntity? processesPagination,
    bool? isLoadingMoreProcesses,
    String? processesLoadMoreErrorMessage,
    bool clearProcessesLoadMoreError = false,
    bool clearProcessesPagination = false,
    String? searchQuery,
    bool? isSearching,
    bool? isLoadingMoreSearch,
    List<EmployeeSearchItemEntity>? searchResults,
    EmployeeSearchPaginationEntity? searchPagination,
    String? searchErrorMessage,
    bool clearSearchError = false,
    bool clearPagination = false,
    String? processSearchQuery,
    bool? isSearchingProcesses,
    bool? isLoadingMoreProcessSearch,
    List<ProcessSearchItemEntity>? processSearchResults,
    ProcessSearchPaginationEntity? processSearchPagination,
    String? processSearchErrorMessage,
    bool clearProcessSearchError = false,
    bool clearProcessPagination = false,
  }) {
    return StatisticsLoaded(
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
      employeesPagination: clearEmployeesPagination
          ? null
          : (employeesPagination ?? this.employeesPagination),
      isLoadingMoreEmployees:
          isLoadingMoreEmployees ?? this.isLoadingMoreEmployees,
      employeesLoadMoreErrorMessage: clearEmployeesLoadMoreError
          ? null
          : (employeesLoadMoreErrorMessage ??
              this.employeesLoadMoreErrorMessage),
      processesPagination: clearProcessesPagination
          ? null
          : (processesPagination ?? this.processesPagination),
      isLoadingMoreProcesses:
          isLoadingMoreProcesses ?? this.isLoadingMoreProcesses,
      processesLoadMoreErrorMessage: clearProcessesLoadMoreError
          ? null
          : (processesLoadMoreErrorMessage ??
              this.processesLoadMoreErrorMessage),
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      isLoadingMoreSearch: isLoadingMoreSearch ?? this.isLoadingMoreSearch,
      searchResults: searchResults ?? this.searchResults,
      searchPagination: clearPagination
          ? null
          : (searchPagination ?? this.searchPagination),
      searchErrorMessage: clearSearchError
          ? null
          : (searchErrorMessage ?? this.searchErrorMessage),
      processSearchQuery: processSearchQuery ?? this.processSearchQuery,
      isSearchingProcesses:
          isSearchingProcesses ?? this.isSearchingProcesses,
      isLoadingMoreProcessSearch:
          isLoadingMoreProcessSearch ?? this.isLoadingMoreProcessSearch,
      processSearchResults: processSearchResults ?? this.processSearchResults,
      processSearchPagination: clearProcessPagination
          ? null
          : (processSearchPagination ?? this.processSearchPagination),
      processSearchErrorMessage: clearProcessSearchError
          ? null
          : (processSearchErrorMessage ?? this.processSearchErrorMessage),
    );
  }
}
