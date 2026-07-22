import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/my_transaction_entity.dart';
import '../../domain/entities/my_transactions_paginated_result.dart';
import '../../domain/usecases/get_my_transactions.dart';
import 'my_transactions_event.dart';
import 'my_transactions_state.dart';

class MyTransactionsBloc
    extends Bloc<MyTransactionsEvent, MyTransactionsState> {
  final GetMyTransactions getMyTransactions;

  static const int _pageLimit = 6;

  /// خريطة تحويل الفلتر العربي إلى قيمة API
  static const Map<String, String> _filterToApiStatus = {
    'الكل': 'all',
    'بانتظار الاستلام': 'pending_pickup',
    'قيد التنفيذ': 'in_progress',
    'منجزة': 'completed',
    'تم الرفض': 'rejected',
  };

  MyTransactionsBloc(this.getMyTransactions) : super(MyTransactionsInitial()) {
    on<LoadMyTransactions>(_onLoadMyTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<FilterMyTransactions>(_onFilterMyTransactions);
    on<SearchMyTransactions>(_onSearchMyTransactions);
    on<SignTransaction>(_onSignTransaction);
    on<RejectTransaction>(_onRejectTransaction);
    on<PickupTransaction>(_onPickupTransaction);
    on<CancelPickupTransaction>(_onCancelPickupTransaction);
  }

  Future<void> _onLoadMyTransactions(
    LoadMyTransactions event,
    Emitter<MyTransactionsState> emit,
  ) async {
    final apiStatus = event.apiStatus;
    final arabicFilter = _filterToApiStatus.entries
        .firstWhere((e) => e.value == apiStatus,
            orElse: () => const MapEntry('الكل', 'all'))
        .key;
    await _fetchDataAndEmit(apiStatus, arabicFilter, emit);
  }

  /// تغيير الفلتر — يعيد تحميل البيانات من API
  Future<void> _onFilterMyTransactions(
    FilterMyTransactions event,
    Emitter<MyTransactionsState> emit,
  ) async {
    final apiStatus = _filterToApiStatus[event.statusFilter] ?? 'all';
    await _fetchDataAndEmit(apiStatus, event.statusFilter, emit);
  }

  Future<void> _fetchDataAndEmit(
    String apiStatus,
    String statusFilter,
    Emitter<MyTransactionsState> emit,
  ) async {
    int oldAwaiting = 0;
    int oldUrgent = 0;
    int oldCompleted = 0;

    if (state is MyTransactionsLoaded) {
      final loaded = state as MyTransactionsLoaded;
      oldAwaiting = loaded.awaitingSignatureCount;
      oldUrgent = loaded.urgentCount;
      oldCompleted = loaded.completedMonthCount;
    }

    emit(MyTransactionsLoading());

    Future<Either<Failure, MyTransactionsPaginatedResult>>? pendingCall;
    if (apiStatus != 'pending_pickup') {
      pendingCall = getMyTransactions(status: 'pending_pickup', limit: 1);
    }

    final result = await getMyTransactions(
      status: apiStatus,
      limit: _pageLimit,
    );

    int pendingCountFromApi = oldAwaiting;
    if (pendingCall != null) {
      final pResult = await pendingCall;
      pResult.fold((_) {}, (r) {
        if (r.totalCount > 0) {
          pendingCountFromApi = r.totalCount;
        }
      });
    }

    result.fold(
      (failure) {
        emit(const MyTransactionsFailure('تعذر تحميل المعاملات الخاصة بك'));
      },
      (paginatedResult) {
        final stats = _calculateStats(paginatedResult.items);

        int finalAwaiting = pendingCountFromApi;
        if (apiStatus == 'pending_pickup') {
          finalAwaiting = paginatedResult.totalCount > 0
              ? paginatedResult.totalCount
              : (stats.awaitingSignature > oldAwaiting
                  ? stats.awaitingSignature
                  : oldAwaiting);
        } else {
          if (pendingCountFromApi == 0 && oldAwaiting > 0) {
            finalAwaiting = oldAwaiting;
          }
        }

        emit(MyTransactionsLoaded(
          transactions: paginatedResult.items,
          statusFilter: statusFilter,
          apiStatusFilter: apiStatus,
          searchQuery: '',
          nextCursor: paginatedResult.nextCursor,
          hasMore: paginatedResult.hasNext,
          isLoadingMore: false,
          awaitingSignatureCount: finalAwaiting,
          urgentCount: stats.urgent > oldUrgent ? stats.urgent : oldUrgent,
          completedMonthCount:
              stats.completed > oldCompleted ? stats.completed : oldCompleted,
        ));
      },
    );
  }

  /// تحميل المزيد (infinite scroll)
  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<MyTransactionsState> emit,
  ) async {
    if (state is! MyTransactionsLoaded) return;
    final loadedState = state as MyTransactionsLoaded;

    // لا نحمل المزيد إذا كان التحميل جارياً أو لا يوجد صفحات إضافية
    if (loadedState.isLoadingMore || !loadedState.hasMore) return;

    emit(loadedState.copyWith(isLoadingMore: true));

    final result = await getMyTransactions(
      status: loadedState.apiStatusFilter,
      cursor: loadedState.nextCursor,
      limit: _pageLimit,
    );

    result.fold(
      (failure) {
        // عند فشل التحميل، نعيد الحالة بدون loading
        emit(loadedState.copyWith(isLoadingMore: false));
      },
      (paginatedResult) {
        final allTransactions = [
          ...loadedState.transactions,
          ...paginatedResult.items
        ];
        final stats = _calculateStats(allTransactions);
        emit(loadedState.copyWith(
          transactions: allTransactions,
          nextCursor: paginatedResult.nextCursor,
          hasMore: paginatedResult.hasNext,
          isLoadingMore: false,
          awaitingSignatureCount: loadedState.apiStatusFilter ==
                      'pending_pickup' &&
                  paginatedResult.totalCount > 0
              ? paginatedResult.totalCount
              : (stats.awaitingSignature > loadedState.awaitingSignatureCount
                  ? stats.awaitingSignature
                  : loadedState.awaitingSignatureCount),
          urgentCount: stats.urgent > loadedState.urgentCount
              ? stats.urgent
              : loadedState.urgentCount,
          completedMonthCount: stats.completed > loadedState.completedMonthCount
              ? stats.completed
              : loadedState.completedMonthCount,
        ));
      },
    );
  }

  void _onSearchMyTransactions(
    SearchMyTransactions event,
    Emitter<MyTransactionsState> emit,
  ) {
    if (state is MyTransactionsLoaded) {
      final loadedState = state as MyTransactionsLoaded;
      emit(loadedState.copyWith(searchQuery: event.query));
    }
  }

  void _onSignTransaction(
    SignTransaction event,
    Emitter<MyTransactionsState> emit,
  ) {
    if (state is MyTransactionsLoaded) {
      final loadedState = state as MyTransactionsLoaded;
      final updatedList = loadedState.transactions.map((tx) {
        if (tx.number == event.txnNumber) {
          return tx.copyWith(
            status: 'منجزة',
            canSign: false,
          );
        }
        return tx;
      }).toList();

      final stats = _calculateStats(updatedList);
      emit(loadedState.copyWith(
        transactions: updatedList,
        awaitingSignatureCount: stats.awaitingSignature,
        urgentCount: stats.urgent,
        completedMonthCount: stats.completed,
      ));
    }
  }

  void _onRejectTransaction(
    RejectTransaction event,
    Emitter<MyTransactionsState> emit,
  ) {
    if (state is MyTransactionsLoaded) {
      final loadedState = state as MyTransactionsLoaded;
      final updatedList = loadedState.transactions.map((tx) {
        if (tx.number == event.txnNumber) {
          return tx.copyWith(
            status: 'تم الرفض',
            canSign: false,
          );
        }
        return tx;
      }).toList();

      final stats = _calculateStats(updatedList);
      emit(loadedState.copyWith(
        transactions: updatedList,
        awaitingSignatureCount: stats.awaitingSignature,
        urgentCount: stats.urgent,
        completedMonthCount: stats.completed,
      ));
    }
  }

  void _onPickupTransaction(
    PickupTransaction event,
    Emitter<MyTransactionsState> emit,
  ) {
    if (state is MyTransactionsLoaded) {
      final loadedState = state as MyTransactionsLoaded;
      final updatedList = loadedState.transactions.map((tx) {
        if (tx.number == event.txnNumber) {
          return tx.copyWith(
            status: 'قيد التنفيذ',
            canSign: true,
          );
        }
        return tx;
      }).toList();

      final stats = _calculateStats(updatedList);
      emit(loadedState.copyWith(
        transactions: updatedList,
        awaitingSignatureCount: stats.awaitingSignature,
        urgentCount: stats.urgent,
        completedMonthCount: stats.completed,
      ));
    }
  }

  void _onCancelPickupTransaction(
    CancelPickupTransaction event,
    Emitter<MyTransactionsState> emit,
  ) {
    if (state is MyTransactionsLoaded) {
      final loadedState = state as MyTransactionsLoaded;
      final updatedList = loadedState.transactions.map((tx) {
        if (tx.number == event.txnNumber) {
          return tx.copyWith(
            status: 'بانتظار الاستلام',
            canSign: true,
          );
        }
        return tx;
      }).toList();

      final stats = _calculateStats(updatedList);
      emit(loadedState.copyWith(
        transactions: updatedList,
        awaitingSignatureCount: stats.awaitingSignature,
        urgentCount: stats.urgent,
        completedMonthCount: stats.completed,
      ));
    }
  }

  /// حساب الإحصائيات من القائمة المحمّلة
  _Stats _calculateStats(List<MyTransactionEntity> list) {
    int awaiting = 0;
    int urgent = 0;
    int completed = 0;

    for (var tx in list) {
      if (tx.status == 'بانتظار الاستلام') {
        awaiting++;
      } else if (tx.status == 'منجزة') {
        completed++;
      }

      if (tx.priority == 'عالية' &&
          (tx.status == 'بانتظار الاستلام' || tx.status == 'قيد التنفيذ')) {
        urgent++;
      }
    }

    return _Stats(awaiting, urgent, completed);
  }
}

class _Stats {
  final int awaitingSignature;
  final int urgent;
  final int completed;

  const _Stats(this.awaitingSignature, this.urgent, this.completed);
}
