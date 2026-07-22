import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:government_employee_dashboard/core/errors/failures.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/usecases/get_department_transactions.dart';
import 'dept_tx_event.dart';
import 'dept_tx_state.dart';

import '../../domain/usecases/get_department_stats.dart';

const _limit = 10;

class DeptTxBloc extends Bloc<DeptTxEvent, DeptTxState> {
  final GetDepartmentTransactions getDepartmentTransactions;
  final GetDepartmentStats getDepartmentStats;

  DeptTxBloc(this.getDepartmentTransactions, this.getDepartmentStats)
      : super(DeptTxInitial()) {
    on<LoadDeptTx>(_onLoadDeptTx);
    on<LoadMoreDeptTx>(_onLoadMoreDeptTx);
    on<FilterDeptTxByStatus>(_onFilterDeptTxByStatus);
    on<FilterDeptTxByDate>(_onFilterDeptTxByDate);
    on<SearchDeptTx>(
      _onSearchDeptTx,
      transformer: (events, mapper) =>
          events.debounce(const Duration(milliseconds: 500)).switchMap(mapper),
    );
  }

  Future<void> _onLoadDeptTx(
      LoadDeptTx event, Emitter<DeptTxState> emit) async {
    final currentState = state;

    String currentStatus = 'منجزة'; // default status
    String? currentFromDate;
    String? currentToDate;
    String currentSearchQuery = '';

    // We want to keep old stats if we have them, so they don't flash to 0 on refresh.
    int completedCount = 0;
    int rejectedCount = 0;
    int activeCount = 0;
    int inProgressCount = 0;
    int pendingPickupCount = 0;

    if (currentState is DeptTxLoaded && !event.isRefresh) {
      currentStatus = currentState.statusFilter;
      currentFromDate = currentState.fromDate;
      currentToDate = currentState.toDate;
      currentSearchQuery = currentState.searchQuery;

      completedCount = currentState.completedCount;
      rejectedCount = currentState.rejectedCount;
      activeCount = currentState.activeCount;
      inProgressCount = currentState.inProgressCount;
      pendingPickupCount = currentState.pendingPickupCount;
    }

    emit(DeptTxLoading());

    final activeRole = getIt<SessionService>().activeRoleNotifier.value;
    final departmentId = activeRole?.departmentId.toString() ?? '1';

    // Fetch transactions and stats in parallel
    final results = await Future.wait([
      getDepartmentTransactions(
        departmentIds: departmentId,
        status: currentStatus,
        fromDate: currentFromDate,
        toDate: currentToDate,
        page: 1,
        limit: _limit,
      ),
      getDepartmentStats(departmentIds: departmentId),
    ]);

    final txResult = results[0] as Either<Failure, Map<String, dynamic>>;
    final statsResult = results[1] as Either<Failure, Map<String, dynamic>>;

    txResult.fold(
      (failure) => emit(DeptTxFailure(failure.message)),
      (data) {
        final items = data['items'] as List<dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;

        final totalCount = pagination['total'] as int? ?? 0;
        final hasNext = pagination['has_next'] as bool? ?? false;

        // If stats succeeded, update them
        statsResult.fold(
          (failure) {}, // Keep old/0 stats on failure
          (statsData) {
            completedCount = statsData['completed_count'] ?? completedCount;
            rejectedCount = statsData['rejected_count'] ?? rejectedCount;
            activeCount = statsData['active_count'] ?? activeCount;
            inProgressCount = statsData['in_progress_count'] ?? inProgressCount;
            pendingPickupCount =
                statsData['pending_pickup_count'] ?? pendingPickupCount;
          },
        );

        emit(DeptTxLoaded(
          transactions: items.cast(),
          statusFilter: currentStatus,
          fromDate: currentFromDate,
          toDate: currentToDate,
          searchQuery: currentSearchQuery,
          page: 1,
          hasReachedMax: !hasNext,
          totalCount: totalCount,
          completedCount: completedCount,
          rejectedCount: rejectedCount,
          activeCount: activeCount,
          inProgressCount: inProgressCount,
          pendingPickupCount: pendingPickupCount,
        ));
      },
    );
  }

  Future<void> _onLoadMoreDeptTx(
      LoadMoreDeptTx event, Emitter<DeptTxState> emit) async {
    final currentState = state;
    if (currentState is! DeptTxLoaded ||
        currentState.hasReachedMax ||
        currentState.isFetchingMore) return;

    emit(currentState.copyWith(isFetchingMore: true));

    final nextPage = currentState.page + 1;

    final activeRole = getIt<SessionService>().activeRoleNotifier.value;
    final departmentId = activeRole?.departmentId.toString() ?? '1';

    final result = await getDepartmentTransactions(
      departmentIds: departmentId,
      status: currentState.statusFilter,
      fromDate: currentState.fromDate,
      toDate: currentState.toDate,
      page: nextPage,
      limit: _limit,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isFetchingMore: false)),
      (data) {
        final items = data['items'] as List<dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        final hasNext = pagination['has_next'] as bool? ?? false;
        final totalCount =
            pagination['total'] as int? ?? currentState.totalCount;

        emit(currentState.copyWith(
          transactions: List.of(currentState.transactions)
            ..addAll(items.cast()),
          page: nextPage,
          hasReachedMax: !hasNext,
          isFetchingMore: false,
          totalCount: totalCount,
        ));
      },
    );
  }

  void _onFilterDeptTxByStatus(
      FilterDeptTxByStatus event, Emitter<DeptTxState> emit) {
    if (state is DeptTxLoaded) {
      final currentState = state as DeptTxLoaded;
      if (currentState.statusFilter == event.statusFilter) return;

      // Update state and trigger load
      emit(currentState.copyWith(statusFilter: event.statusFilter));
      add(const LoadDeptTx());
    } else {
      // If not loaded yet (initial), we just Load with that status.
      // But we need a way to pass status to LoadDeptTx if we don't store it.
      // Easiest is to wait for LoadDeptTx to finish, then filter. Or just trigger load.
      add(const LoadDeptTx());
    }
  }

  void _onFilterDeptTxByDate(
      FilterDeptTxByDate event, Emitter<DeptTxState> emit) {
    if (state is DeptTxLoaded) {
      final currentState = state as DeptTxLoaded;
      emit(currentState.copyWith(
          fromDate: event.fromDate, toDate: event.toDate));
      add(const LoadDeptTx());
    }
  }

  void _onSearchDeptTx(SearchDeptTx event, Emitter<DeptTxState> emit) {
    if (state is DeptTxLoaded) {
      final currentState = state as DeptTxLoaded;
      emit(currentState.copyWith(searchQuery: event.query));
      add(const LoadDeptTx());
    }
  }
}
