import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/transaction_type_entity.dart';
import '../../domain/usecases/get_process_definitions.dart';
import '../../domain/usecases/get_transaction_types.dart';
import 'directorate_process_event.dart';
import 'directorate_process_state.dart';

class DirectorateProcessBloc
    extends Bloc<DirectorateProcessEvent, DirectorateProcessState> {
  static const int limit = 20;

  final GetTransactionTypes getTransactionTypes;
  final GetProcessDefinitions getProcessDefinitions;
  final Set<String> _requestedPages = <String>{};

  DirectorateProcessBloc({
    required this.getTransactionTypes,
    required this.getProcessDefinitions,
  }) : super(const DirectorateProcessState()) {
    on<LoadTransactionTypes>(_loadTypes);
    on<SearchTransactionTypes>(_searchTypes);
    on<LoadProcessDefinitions>(_loadInitialDefinitions);
    on<LoadMoreProcessDefinitions>(_loadMoreDefinitions);
    on<RetryLoadMoreProcessDefinitions>(_retryLoadMore);
    on<SearchProcessDefinitions>(_searchDefinitions);
    on<BackToTransactionTypes>(_back);
    on<RetryCurrentRequest>(_retryCurrent);
  }

  Future<void> _loadTypes(
    LoadTransactionTypes event,
    Emitter<DirectorateProcessState> emit,
  ) async {
    emit(state.copyWith(isTypesLoading: true, clearError: true));
    final result = await getTransactionTypes();
    result.fold(
      (failure) => emit(state.copyWith(
        isTypesLoading: false,
        errorMessage: failure.message,
      )),
      (types) => emit(state.copyWith(
        isTypesLoading: false,
        types: types,
        filteredTypes: _filterTypes(types, state.typesQuery),
        clearError: true,
      )),
    );
  }

  void _searchTypes(
    SearchTransactionTypes event,
    Emitter<DirectorateProcessState> emit,
  ) {
    emit(state.copyWith(
      typesQuery: event.query,
      filteredTypes: _filterTypes(state.types, event.query),
    ));
  }

  Future<void> _loadInitialDefinitions(
    LoadProcessDefinitions event,
    Emitter<DirectorateProcessState> emit,
  ) async {
    _requestedPages.clear();
    const page = 1;
    final requestKey = _requestKey(event.typeId, page);
    _requestedPages.add(requestKey);

    emit(state.copyWith(
      view: DirectorateView.definitions,
      selectedTypeId: event.typeId,
      selectedTypeName: event.typeName,
      items: const [],
      currentPage: 0,
      totalPages: 0,
      total: 0,
      hasNext: true,
      isInitialLoading: true,
      isLoadingMore: false,
      definitionsQuery: '',
      clearError: true,
      clearLoadMoreError: true,
    ));

    final result = await getProcessDefinitions(
      typeId: event.typeId,
      page: page,
      limit: limit,
    );
    if (state.selectedTypeId != event.typeId) return;

    result.fold(
      (failure) {
        _requestedPages.remove(requestKey);
        emit(state.copyWith(
          isInitialLoading: false,
          errorMessage: failure.message,
        ));
      },
      (response) => emit(state.copyWith(
        items: response.items,
        currentPage: response.pagination.page,
        totalPages: response.pagination.totalPages,
        total: response.pagination.total,
        hasNext: response.pagination.hasNext,
        isInitialLoading: false,
        clearError: true,
      )),
    );
  }

  Future<void> _loadMoreDefinitions(
    LoadMoreProcessDefinitions event,
    Emitter<DirectorateProcessState> emit,
  ) async {
    final typeId = state.selectedTypeId;
    if (typeId == null || state.isLoadingMore || !state.hasNext) return;

    final nextPage = state.currentPage + 1;
    final requestKey = _requestKey(typeId, nextPage);
    if (_requestedPages.contains(requestKey)) return;
    _requestedPages.add(requestKey);

    emit(state.copyWith(
      isLoadingMore: true,
      clearLoadMoreError: true,
    ));

    final result = await getProcessDefinitions(
      typeId: typeId,
      page: nextPage,
      limit: limit,
    );
    if (state.selectedTypeId != typeId) return;

    result.fold(
      (failure) {
        _requestedPages.remove(requestKey);
        emit(state.copyWith(
          isLoadingMore: false,
          loadMoreError: failure.message,
        ));
      },
      (response) {
        final mergedItems = List.of(state.items)..addAll(response.items);
        emit(state.copyWith(
          items: mergedItems,
          currentPage: response.pagination.page,
          totalPages: response.pagination.totalPages,
          total: response.pagination.total,
          hasNext: response.pagination.hasNext,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ));
      },
    );
  }

  void _retryLoadMore(
    RetryLoadMoreProcessDefinitions event,
    Emitter<DirectorateProcessState> emit,
  ) {
    if (!state.isLoadingMore && state.hasNext) {
      add(const LoadMoreProcessDefinitions());
    }
  }

  void _searchDefinitions(
    SearchProcessDefinitions event,
    Emitter<DirectorateProcessState> emit,
  ) {
    // This search deliberately filters only pages already loaded in [items].
    emit(state.copyWith(definitionsQuery: event.query));
  }

  void _back(
    BackToTransactionTypes event,
    Emitter<DirectorateProcessState> emit,
  ) {
    emit(state.copyWith(view: DirectorateView.types, clearError: true));
  }

  void _retryCurrent(
    RetryCurrentRequest event,
    Emitter<DirectorateProcessState> emit,
  ) {
    if (state.view == DirectorateView.types) {
      add(const LoadTransactionTypes());
    } else if (state.selectedTypeId != null) {
      add(LoadProcessDefinitions(
        typeId: state.selectedTypeId!,
        typeName: state.selectedTypeName ?? '',
      ));
    }
  }

  String _requestKey(int typeId, int page) => '$typeId:$page';

  List<TransactionTypeEntity> _filterTypes(
    List<TransactionTypeEntity> items,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return items;
    return items.where((item) {
      return item.name.toLowerCase().contains(normalized) ||
          item.code.toLowerCase().contains(normalized);
    }).toList(growable: false);
  }
}
