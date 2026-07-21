import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_complaint_process_definitions.dart';
import 'directorate_complaints_event.dart';
import 'directorate_complaints_state.dart';

class DirectorateComplaintsBloc
    extends Bloc<DirectorateComplaintsEvent, DirectorateComplaintsState> {
  static const int limit = 20;

  final GetComplaintProcessDefinitions getComplaints;
  final Set<int> _requestedPages = <int>{};

  DirectorateComplaintsBloc({required this.getComplaints})
      : super(const DirectorateComplaintsState()) {
    on<LoadDirectorateComplaints>(_loadInitial);
    on<LoadMoreDirectorateComplaints>(_loadMore);
    on<RetryDirectorateComplaints>(_retryInitial);
    on<RetryMoreDirectorateComplaints>(_retryMore);
    on<SearchDirectorateComplaints>(_search);
  }

  Future<void> _loadInitial(
    LoadDirectorateComplaints event,
    Emitter<DirectorateComplaintsState> emit,
  ) async {
    if (state.isInitialLoading || state.items.isNotEmpty) return;
    _requestedPages.clear();
    _requestedPages.add(1);
    emit(state.copyWith(
      isInitialLoading: true,
      errorMessage: null,
      loadMoreError: null,
      currentPage: 0,
      hasNext: true,
    ));
    final result = await getComplaints(page: 1, limit: limit);
    result.fold(
      (failure) {
        _requestedPages.remove(1);
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
        errorMessage: null,
      )),
    );
  }

  Future<void> _loadMore(
    LoadMoreDirectorateComplaints event,
    Emitter<DirectorateComplaintsState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasNext || state.items.isEmpty) return;
    final nextPage = state.currentPage + 1;
    if (_requestedPages.contains(nextPage)) return;
    _requestedPages.add(nextPage);
    emit(state.copyWith(isLoadingMore: true, loadMoreError: null));
    final result = await getComplaints(page: nextPage, limit: limit);
    result.fold(
      (failure) {
        _requestedPages.remove(nextPage);
        emit(state.copyWith(
          isLoadingMore: false,
          loadMoreError: failure.message,
        ));
      },
      (response) => emit(state.copyWith(
        items: [...state.items, ...response.items],
        currentPage: response.pagination.page,
        totalPages: response.pagination.totalPages,
        total: response.pagination.total,
        hasNext: response.pagination.hasNext,
        isLoadingMore: false,
        loadMoreError: null,
      )),
    );
  }

  void _retryInitial(
    RetryDirectorateComplaints event,
    Emitter<DirectorateComplaintsState> emit,
  ) {
    if (state.items.isEmpty) add(const LoadDirectorateComplaints());
  }

  void _retryMore(
    RetryMoreDirectorateComplaints event,
    Emitter<DirectorateComplaintsState> emit,
  ) {
    if (state.loadMoreError != null) {
      add(const LoadMoreDirectorateComplaints());
    }
  }

  void _search(
    SearchDirectorateComplaints event,
    Emitter<DirectorateComplaintsState> emit,
  ) =>
      emit(state.copyWith(query: event.query));
}
