import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../domain/usecases/get_department_transactions.dart';
import 'dept_tx_event.dart';
import 'dept_tx_state.dart';

const _limit = 10;

class DeptTxBloc extends Bloc<DeptTxEvent, DeptTxState> {
  final GetDepartmentTransactions getDepartmentTransactions;

  DeptTxBloc(this.getDepartmentTransactions) : super(DeptTxInitial()) {
    on<LoadDeptTx>(_onLoadDeptTx);
    on<LoadMoreDeptTx>(_onLoadMoreDeptTx);
    on<FilterDeptTxByStatus>(_onFilterDeptTxByStatus);
    on<FilterDeptTxByDate>(_onFilterDeptTxByDate);
    on<SearchDeptTx>(
      _onSearchDeptTx,
      transformer: (events, mapper) => events.debounce(const Duration(milliseconds: 500)).switchMap(mapper),
    );
  }

  Future<void> _onLoadDeptTx(LoadDeptTx event, Emitter<DeptTxState> emit) async {
    final currentState = state;
    
    String currentStatus = 'منجزة'; // default status
    String? currentFromDate;
    String? currentToDate;
    String currentSearchQuery = '';

    if (currentState is DeptTxLoaded && !event.isRefresh) {
      currentStatus = currentState.statusFilter;
      currentFromDate = currentState.fromDate;
      currentToDate = currentState.toDate;
      currentSearchQuery = currentState.searchQuery;
    }

    emit(DeptTxLoading());

    final result = await getDepartmentTransactions(
      departmentIds: '1', // TODO: Get this dynamically from user profile or filter
      status: currentStatus,
      fromDate: currentFromDate,
      toDate: currentToDate,
      page: 1,
      limit: _limit,
    );

    result.fold(
      (failure) => emit(DeptTxFailure(failure.message)),
      (data) {
        final items = data['items'] as List<dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        
        final totalCount = pagination['total'] as int? ?? 0;
        final hasNext = pagination['has_next'] as bool? ?? false;

        // Note: API search is not natively available via query parameters based on swagger yet, 
        // but we keep the searchQuery state if the API is updated to support it, 
        // or we filter the fetched page locally (not ideal for paginated APIs).
        // Since we don't have a search API, we will just hold the state.

        emit(DeptTxLoaded(
          transactions: items.cast(),
          statusFilter: currentStatus,
          fromDate: currentFromDate,
          toDate: currentToDate,
          searchQuery: currentSearchQuery,
          page: 1,
          hasReachedMax: !hasNext,
          totalCount: totalCount,
        ));
      },
    );
  }

  Future<void> _onLoadMoreDeptTx(LoadMoreDeptTx event, Emitter<DeptTxState> emit) async {
    final currentState = state;
    if (currentState is! DeptTxLoaded || currentState.hasReachedMax || currentState.isFetchingMore) return;

    emit(currentState.copyWith(isFetchingMore: true));

    final nextPage = currentState.page + 1;

    final result = await getDepartmentTransactions(
      departmentIds: '1', // TODO: Get this dynamically from user profile or filter
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
        final totalCount = pagination['total'] as int? ?? currentState.totalCount;

        emit(currentState.copyWith(
          transactions: List.of(currentState.transactions)..addAll(items.cast()),
          page: nextPage,
          hasReachedMax: !hasNext,
          isFetchingMore: false,
          totalCount: totalCount,
        ));
      },
    );
  }

  void _onFilterDeptTxByStatus(FilterDeptTxByStatus event, Emitter<DeptTxState> emit) {
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

  void _onFilterDeptTxByDate(FilterDeptTxByDate event, Emitter<DeptTxState> emit) {
    if (state is DeptTxLoaded) {
      final currentState = state as DeptTxLoaded;
      emit(currentState.copyWith(fromDate: event.fromDate, toDate: event.toDate));
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
