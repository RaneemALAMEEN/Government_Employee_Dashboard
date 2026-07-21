import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_my_notifications.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  static const int limit = 10;

  final GetMyNotifications getMyNotifications;
  final Set<String> _requestedCursors = <String>{};
  int _generation = 0;

  NotificationsBloc({required this.getMyNotifications})
      : super(const NotificationsState()) {
    on<LoadNotifications>(_loadInitial);
    on<LoadMoreNotifications>(_loadMore);
    on<ChangeNotificationFilter>(_changeFilter);
    on<RetryLoadMoreNotifications>(_retryMore);
    on<RetryNotifications>(_retryInitial);
  }

  Future<void> _loadInitial(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.isInitialLoading ||
        (state.items.isNotEmpty && state.unreadOnly == event.unreadOnly)) {
      return;
    }
    if (state.unreadOnly != event.unreadOnly) {
      _generation++;
      _requestedCursors.clear();
    }
    final generation = _generation;
    final requestKey = '${event.unreadOnly}:initial';
    if (_requestedCursors.contains(requestKey)) return;
    _requestedCursors.add(requestKey);
    emit(NotificationsState(
      unreadOnly: event.unreadOnly,
      isInitialLoading: true,
      unreadCount: state.unreadCount,
    ));

    final result = await getMyNotifications(
      limit: limit,
      unreadOnly: event.unreadOnly,
    );
    if (generation != _generation) return;
    result.fold(
      (failure) {
        _requestedCursors.remove(requestKey);
        emit(state.copyWith(
          isInitialLoading: false,
          errorMessage: failure.message,
        ));
      },
      (response) {
        final pagination = response.pagination;
        emit(state.copyWith(
          items: response.items,
          isInitialLoading: false,
          hasNext: pagination.hasNext && pagination.nextCursor != null,
          nextCursor: pagination.nextCursor,
          unreadCount: response.unreadCount,
          errorMessage: null,
        ));
      },
    );
  }

  Future<void> _loadMore(
    LoadMoreNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasNext) return;
    final cursor = state.nextCursor;
    if (cursor == null || cursor.isEmpty) return;
    final requestKey = '${state.unreadOnly}:$cursor';
    if (_requestedCursors.contains(requestKey)) return;
    _requestedCursors.add(requestKey);
    final generation = _generation;
    final unreadOnly = state.unreadOnly;
    emit(state.copyWith(isLoadingMore: true, loadMoreError: null));

    final result = await getMyNotifications(
      limit: limit,
      cursor: cursor,
      unreadOnly: unreadOnly,
    );
    if (generation != _generation) return;
    result.fold(
      (failure) {
        _requestedCursors.remove(requestKey);
        emit(state.copyWith(
          isLoadingMore: false,
          loadMoreError: failure.message,
        ));
      },
      (response) {
        final pagination = response.pagination;
        emit(state.copyWith(
          items: [...state.items, ...response.items],
          isLoadingMore: false,
          hasNext: pagination.hasNext && pagination.nextCursor != null,
          nextCursor: pagination.nextCursor,
          unreadCount: response.unreadCount,
          loadMoreError: null,
        ));
      },
    );
  }

  void _changeFilter(
    ChangeNotificationFilter event,
    Emitter<NotificationsState> emit,
  ) {
    if (state.unreadOnly == event.unreadOnly) return;
    _generation++;
    _requestedCursors.clear();
    emit(NotificationsState(
      unreadOnly: event.unreadOnly,
      unreadCount: state.unreadCount,
    ));
    add(LoadNotifications(unreadOnly: event.unreadOnly));
  }

  void _retryMore(
    RetryLoadMoreNotifications event,
    Emitter<NotificationsState> emit,
  ) {
    if (state.loadMoreError != null) add(const LoadMoreNotifications());
  }

  void _retryInitial(
    RetryNotifications event,
    Emitter<NotificationsState> emit,
  ) {
    if (state.items.isEmpty) {
      add(LoadNotifications(unreadOnly: state.unreadOnly));
    }
  }
}
