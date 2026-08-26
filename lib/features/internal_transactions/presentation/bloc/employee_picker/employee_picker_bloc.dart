import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/self_card_entity.dart';
import '../../../domain/usecases/get_self_card_details_usecase.dart';
import '../../../domain/usecases/search_self_cards_usecase.dart';
import 'employee_picker_event.dart';
import 'employee_picker_state.dart';

class EmployeePickerBloc
    extends Bloc<EmployeePickerEvent, EmployeePickerState> {
  static const int limit = 20;
  static const Duration searchDebounce = Duration(milliseconds: 450);

  final SearchSelfCardsUseCase searchSelfCards;
  final GetSelfCardDetailsUseCase getSelfCardDetails;

  final Set<String> _inFlightRequests = <String>{};
  final Set<String> _consumedCursors = <String>{};
  final Map<int, SelfCardDetailsEntity> _detailsCache = {};
  Timer? _debounce;
  int _searchGeneration = 0;
  int _detailsGeneration = 0;

  EmployeePickerBloc({
    required this.searchSelfCards,
    required this.getSelfCardDetails,
  }) : super(const EmployeePickerState()) {
    on<EmployeePickerOpened>(_onOpened);
    on<EmployeePickerQueryChanged>(_onQueryChanged);
    on<ExecuteEmployeePickerSearch>(_onExecuteSearch);
    on<EmployeePickerLoadMore>(_onLoadMore);
    on<EmployeePickerRetrySearch>(_onRetrySearch);
    on<EmployeePickerSelected>(_onSelected);
    on<EmployeePickerValueHydrated>(_onValueHydrated);
    on<EmployeePickerSelectionCleared>(_onSelectionCleared);
    on<EmployeePickerRetryDetails>(_onRetryDetails);
  }

  void _onOpened(
    EmployeePickerOpened event,
    Emitter<EmployeePickerState> emit,
  ) {
    if (state.searchInitialLoading ||
        state.searchStatus == SelfCardSearchStatus.success ||
        state.searchStatus == SelfCardSearchStatus.empty) {
      return;
    }
    final generation = ++_searchGeneration;
    add(ExecuteEmployeePickerSearch(
        query: state.query, generation: generation));
  }

  void _onQueryChanged(
    EmployeePickerQueryChanged event,
    Emitter<EmployeePickerState> emit,
  ) {
    _debounce?.cancel();
    final query = event.query.trim();
    final generation = ++_searchGeneration;
    _consumedCursors.clear();

    if (query.length == 1) {
      emit(state.copyWith(
        query: query,
        items: const [],
        searchStatus: SelfCardSearchStatus.initial,
        searchLoadingMore: false,
        hasNext: false,
        clearNextCursor: true,
        clearSearchError: true,
        clearLoadMoreError: true,
      ));
      return;
    }

    emit(state.copyWith(
      query: query,
      items: const [],
      searchStatus: SelfCardSearchStatus.initialLoading,
      searchLoadingMore: false,
      hasNext: false,
      clearNextCursor: true,
      clearSearchError: true,
      clearLoadMoreError: true,
    ));

    if (query.isEmpty) {
      add(ExecuteEmployeePickerSearch(query: query, generation: generation));
      return;
    }

    _debounce = Timer(searchDebounce, () {
      add(ExecuteEmployeePickerSearch(query: query, generation: generation));
    });
  }

  Future<void> _onExecuteSearch(
    ExecuteEmployeePickerSearch event,
    Emitter<EmployeePickerState> emit,
  ) async {
    if (event.generation != _searchGeneration) return;
    final requestKey = '${event.query}|initial';
    if (!_inFlightRequests.add(requestKey)) return;

    emit(state.copyWith(
      query: event.query,
      items: const [],
      searchStatus: SelfCardSearchStatus.initialLoading,
      searchLoadingMore: false,
      hasNext: false,
      clearNextCursor: true,
      clearSearchError: true,
      clearLoadMoreError: true,
    ));

    final result = await searchSelfCards(
      query: event.query.isEmpty ? null : event.query,
      limit: limit,
      activeOnly: true,
    );
    _inFlightRequests.remove(requestKey);
    if (state.query != event.query) return;

    result.fold(
      (failure) {
        emit(state.copyWith(
          searchStatus: SelfCardSearchStatus.failure,
          searchError: failure.message,
          hasNext: false,
          clearNextCursor: true,
        ));
      },
      (response) => emit(state.copyWith(
        items: response.items,
        searchStatus: response.items.isEmpty
            ? SelfCardSearchStatus.empty
            : SelfCardSearchStatus.success,
        hasNext: response.pagination.hasNext &&
            response.pagination.nextCursor != null,
        nextCursor: response.pagination.nextCursor,
        clearNextCursor: response.pagination.nextCursor == null,
        clearSearchError: true,
      )),
    );
  }

  Future<void> _onLoadMore(
    EmployeePickerLoadMore event,
    Emitter<EmployeePickerState> emit,
  ) async {
    if (state.searchLoadingMore || !state.hasNext) return;
    final cursor = state.nextCursor;
    if (cursor == null || cursor.isEmpty) return;
    final requestKey = '${state.query}|$cursor';
    if (_consumedCursors.contains(requestKey) ||
        !_inFlightRequests.add(requestKey)) {
      return;
    }
    final generation = _searchGeneration;

    emit(state.copyWith(
      searchLoadingMore: true,
      clearLoadMoreError: true,
    ));
    final result = await searchSelfCards(
      query: state.query.isEmpty ? null : state.query,
      cursor: cursor,
      limit: limit,
      activeOnly: true,
    );
    _inFlightRequests.remove(requestKey);
    if (generation != _searchGeneration) return;

    result.fold(
      (failure) {
        emit(state.copyWith(
          searchLoadingMore: false,
          loadMoreError: failure.message,
        ));
      },
      (response) {
        _consumedCursors.add(requestKey);
        emit(state.copyWith(
          items: _mergeById(state.items, response.items),
          searchStatus: SelfCardSearchStatus.success,
          searchLoadingMore: false,
          hasNext: response.pagination.hasNext &&
              response.pagination.nextCursor != null,
          nextCursor: response.pagination.nextCursor,
          clearNextCursor: response.pagination.nextCursor == null,
          clearLoadMoreError: true,
        ));
      },
    );
  }

  void _onRetrySearch(
    EmployeePickerRetrySearch event,
    Emitter<EmployeePickerState> emit,
  ) {
    if (state.loadMoreError != null && state.items.isNotEmpty) {
      add(const EmployeePickerLoadMore());
      return;
    }
    final generation = ++_searchGeneration;
    add(ExecuteEmployeePickerSearch(
        query: state.query, generation: generation));
  }

  Future<void> _onSelected(
    EmployeePickerSelected event,
    Emitter<EmployeePickerState> emit,
  ) async {
    final generation = ++_detailsGeneration;
    final cached = _detailsCache[event.item.id];
    if (cached != null) {
      emit(state.copyWith(
        selectedCard: event.item,
        selectedDetails: cached,
        detailsStatus: SelfCardDetailsStatus.success,
        clearDetailsError: true,
      ));
      return;
    }

    emit(state.copyWith(
      selectedCard: event.item,
      clearSelectedDetails: true,
      detailsStatus: SelfCardDetailsStatus.loading,
      clearDetailsError: true,
    ));
    final result = await getSelfCardDetails(id: event.item.id);
    if (generation != _detailsGeneration) return;
    result.fold(
      (failure) => emit(state.copyWith(
        detailsStatus: SelfCardDetailsStatus.failure,
        detailsError: failure.message,
      )),
      (details) {
        _detailsCache[details.id] = details;
        emit(state.copyWith(
          selectedDetails: details,
          detailsStatus: SelfCardDetailsStatus.success,
          clearDetailsError: true,
        ));
      },
    );
  }

  Future<void> _onValueHydrated(
    EmployeePickerValueHydrated event,
    Emitter<EmployeePickerState> emit,
  ) async {
    final cached = _detailsCache[event.id];
    if (cached != null) {
      emit(state.copyWith(
        selectedCard: cached,
        selectedDetails: cached,
        detailsStatus: SelfCardDetailsStatus.success,
        clearDetailsError: true,
      ));
      return;
    }
    final generation = ++_detailsGeneration;
    emit(state.copyWith(
      clearSelection: true,
      detailsStatus: SelfCardDetailsStatus.loading,
    ));
    final result = await getSelfCardDetails(id: event.id);
    if (generation != _detailsGeneration) return;
    result.fold(
      (failure) => emit(state.copyWith(
        detailsStatus: SelfCardDetailsStatus.failure,
        detailsError: failure.message,
      )),
      (details) {
        _detailsCache[details.id] = details;
        emit(state.copyWith(
          selectedCard: details,
          selectedDetails: details,
          detailsStatus: SelfCardDetailsStatus.success,
          clearDetailsError: true,
        ));
      },
    );
  }

  void _onSelectionCleared(
    EmployeePickerSelectionCleared event,
    Emitter<EmployeePickerState> emit,
  ) {
    _detailsGeneration++;
    emit(state.copyWith(clearSelection: true));
  }

  void _onRetryDetails(
    EmployeePickerRetryDetails event,
    Emitter<EmployeePickerState> emit,
  ) {
    final selected = state.selectedCard;
    if (selected != null) add(EmployeePickerSelected(selected));
  }

  List<SelfCardEntity> _mergeById(
    List<SelfCardEntity> current,
    List<SelfCardEntity> incoming,
  ) {
    final merged = <int, SelfCardEntity>{
      for (final item in current) item.id: item,
    };
    for (final item in incoming) {
      merged[item.id] = item;
    }
    return merged.values.toList(growable: false);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
