import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_my_transaction_counts_usecase.dart';
import '../../domain/usecases/get_my_transactions_usecase.dart';
import 'internal_transactions_event.dart';
import 'internal_transactions_state.dart';

class InternalTransactionsBloc
    extends Bloc<InternalTransactionsEvent, InternalTransactionsState> {
  final GetMyTransactionCountsUseCase getMyTransactionCounts;
  final GetMyTransactionsUseCase getMyTransactions;

  static const int _limit = 10;

  InternalTransactionsBloc({
    required this.getMyTransactionCounts,
    required this.getMyTransactions,
  }) : super(InternalTransactionsState.initial()) {
    on<LoadInternalTransactionsOverview>(_onLoadOverview);
    on<LoadInternalTransactionsPage>(_onLoadPage);
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

    add(const LoadInternalTransactionsPage(page: 1));
  }

  Future<void> _onLoadPage(
    LoadInternalTransactionsPage event,
    Emitter<InternalTransactionsState> emit,
  ) async {
    emit(
      state.copyWith(
        loadingTransactions: true,
        clearError: true,
      ),
    );

    final result = await getMyTransactions(
      page: event.page,
      limit: _limit,
      status: event.status,
    );

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
        emit(
          state.copyWith(
            loadingTransactions: false,
            transactionsPageData: pageData,
          ),
        );
      },
    );
  }
}