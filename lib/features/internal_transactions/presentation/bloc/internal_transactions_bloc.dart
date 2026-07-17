import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_my_transaction_counts_usecase.dart';
import '../../domain/usecases/get_my_transactions_usecase.dart';
import '../../domain/entities/internal_transactions_page_entity.dart';
import 'internal_transactions_event.dart';
import 'internal_transactions_state.dart';

class InternalTransactionsBloc
    extends Bloc<InternalTransactionsEvent, InternalTransactionsState> {
  final GetMyTransactionCountsUseCase getMyTransactionCounts;
  final GetMyTransactionsUseCase getMyTransactions;

  static const int _limit = 6;

  InternalTransactionsBloc({
    required this.getMyTransactionCounts,
    required this.getMyTransactions,
  }) : super(InternalTransactionsState.initial()) {
    on<LoadInternalTransactionsOverview>(_onLoadOverview);
    on<LoadInternalTransactionsPage>(_onLoadPage);
    on<LoadMoreInternalTransactions>(_onLoadMore);
  }

  Future<void> _onLoadOverview(
    LoadInternalTransactionsOverview event,
    Emitter<InternalTransactionsState> emit,
  ) async {
    emit(
      state.copyWith(
        loadingCounts: true,
        loadingTransactions: true,
        clearError: true,
      ),
    );

    final countsResult = await getMyTransactionCounts();
    if (emit.isDone) return;

    countsResult.fold(
      (failure) {
        emit(
          state.copyWith(
            loadingCounts: false,
            errorMessage: failure.message,
          ),
        );
      },
      (counts) {
        emit(
          state.copyWith(
            loadingCounts: false,
            counts: counts,
          ),
        );
      },
    );

    await _loadTransactionsPage(
      page: 1,
      status: null,
      emit: emit,
      clearError: false,
    );
  }

  Future<void> _onLoadPage(
    LoadInternalTransactionsPage event,
    Emitter<InternalTransactionsState> emit,
  ) async {
    await _loadTransactionsPage(
      page: event.page,
      status: event.status,
      emit: emit,
    );
  }

  Future<void> _onLoadMore(
    LoadMoreInternalTransactions event,
    Emitter<InternalTransactionsState> emit,
  ) async {
    final currentData = state.transactionsPageData;
    if (currentData == null ||
        state.loadingTransactions ||
        !state.hasMoreTransactions) {
      return;
    }

    await _loadTransactionsPage(
      page: currentData.page + 1,
      status: null,
      emit: emit,
      append: true,
    );
  }

  Future<void> _loadTransactionsPage({
    required int page,
    required String? status,
    required Emitter<InternalTransactionsState> emit,
    bool clearError = true,
    bool append = false,
  }) async {
    if (emit.isDone) return;

    emit(
      state.copyWith(
        loadingTransactions: true,
        clearError: clearError,
      ),
    );

    final result = await getMyTransactions(
      page: page,
      limit: _limit,
      status: status,
    );
    if (emit.isDone) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            loadingTransactions: false,
            errorMessage: failure.message,
          ),
        );
      },
      (pageData) {
        final currentItems = state.transactionsPageData?.items ?? const [];
        final resultData = append
            ? InternalTransactionsPageEntity(
                items: [...currentItems, ...pageData.items],
                page: page,
                limit: pageData.limit,
                total: pageData.total,
                totalPages: pageData.totalPages,
                hasNext: pageData.hasNext,
                hasPrev: pageData.hasPrev,
              )
            : pageData;

        emit(
          state.copyWith(
            loadingTransactions: false,
            hasMoreTransactions: pageData.items.length >= _limit,
            transactionsPageData: resultData,
          ),
        );
      },
    );
  }
}
