import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/my_transaction_entity.dart';
import '../../domain/usecases/get_my_transactions.dart';
import 'my_transactions_event.dart';
import 'my_transactions_state.dart';

class MyTransactionsBloc extends Bloc<MyTransactionsEvent, MyTransactionsState> {
  final GetMyTransactions getMyTransactions;

  MyTransactionsBloc(this.getMyTransactions) : super(MyTransactionsInitial()) {
    on<LoadMyTransactions>(_onLoadMyTransactions);
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
    emit(MyTransactionsLoading());
    try {
      final txs = await getMyTransactions();
      final stats = _calculateStats(txs);
      emit(MyTransactionsLoaded(
        allTransactions: txs,
        filteredTransactions: txs,
        statusFilter: 'الكل',
        searchQuery: '',
        awaitingSignatureCount: stats.awaitingSignature,
        urgentCount: stats.urgent,
        completedMonthCount: stats.completed,
      ));
    } catch (_) {
      emit(const MyTransactionsFailure('تعذر تحميل المعاملات الخاصة بك'));
    }
  }

  void _onFilterMyTransactions(
    FilterMyTransactions event,
    Emitter<MyTransactionsState> emit,
  ) {
    if (state is MyTransactionsLoaded) {
      final loadedState = state as MyTransactionsLoaded;
      final filtered = _filterList(
        loadedState.allTransactions,
        event.statusFilter,
        loadedState.searchQuery,
      );
      emit(loadedState.copyWith(
        statusFilter: event.statusFilter,
        filteredTransactions: filtered,
      ));
    }
  }

  void _onSearchMyTransactions(
    SearchMyTransactions event,
    Emitter<MyTransactionsState> emit,
  ) {
    if (state is MyTransactionsLoaded) {
      final loadedState = state as MyTransactionsLoaded;
      final filtered = _filterList(
        loadedState.allTransactions,
        loadedState.statusFilter,
        event.query,
      );
      emit(loadedState.copyWith(
        searchQuery: event.query,
        filteredTransactions: filtered,
      ));
    }
  }

  void _onSignTransaction(
    SignTransaction event,
    Emitter<MyTransactionsState> emit,
  ) {
    if (state is MyTransactionsLoaded) {
      final loadedState = state as MyTransactionsLoaded;
      final updatedList = loadedState.allTransactions.map((tx) {
        if (tx.number == event.txnNumber) {
          return tx.copyWith(
            status: 'منجزة',
            canSign: false,
          );
        }
        return tx;
      }).toList();

      final stats = _calculateStats(updatedList);
      final filtered = _filterList(
        updatedList,
        loadedState.statusFilter,
        loadedState.searchQuery,
      );

      emit(MyTransactionsLoaded(
        allTransactions: updatedList,
        filteredTransactions: filtered,
        statusFilter: loadedState.statusFilter,
        searchQuery: loadedState.searchQuery,
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
      final updatedList = loadedState.allTransactions.map((tx) {
        if (tx.number == event.txnNumber) {
          return tx.copyWith(
            status: 'تم الرفض',
            canSign: false,
          );
        }
        return tx;
      }).toList();

      final stats = _calculateStats(updatedList);
      final filtered = _filterList(
        updatedList,
        loadedState.statusFilter,
        loadedState.searchQuery,
      );

      emit(MyTransactionsLoaded(
        allTransactions: updatedList,
        filteredTransactions: filtered,
        statusFilter: loadedState.statusFilter,
        searchQuery: loadedState.searchQuery,
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
      final updatedList = loadedState.allTransactions.map((tx) {
        if (tx.number == event.txnNumber) {
          return tx.copyWith(
            status: 'قيد التنفيذ',
            canSign: true,
          );
        }
        return tx;
      }).toList();

      final stats = _calculateStats(updatedList);
      final filtered = _filterList(
        updatedList,
        loadedState.statusFilter,
        loadedState.searchQuery,
      );

      emit(MyTransactionsLoaded(
        allTransactions: updatedList,
        filteredTransactions: filtered,
        statusFilter: loadedState.statusFilter,
        searchQuery: loadedState.searchQuery,
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
      final updatedList = loadedState.allTransactions.map((tx) {
        if (tx.number == event.txnNumber) {
          return tx.copyWith(
            status: 'بانتظار الاستلام',
            canSign: true,
          );
        }
        return tx;
      }).toList();

      final stats = _calculateStats(updatedList);
      final filtered = _filterList(
        updatedList,
        loadedState.statusFilter,
        loadedState.searchQuery,
      );

      emit(MyTransactionsLoaded(
        allTransactions: updatedList,
        filteredTransactions: filtered,
        statusFilter: loadedState.statusFilter,
        searchQuery: loadedState.searchQuery,
        awaitingSignatureCount: stats.awaitingSignature,
        urgentCount: stats.urgent,
        completedMonthCount: stats.completed,
      ));
    }
  }

  List<MyTransactionEntity> _filterList(
    List<MyTransactionEntity> list,
    String statusFilter,
    String query,
  ) {
    var filtered = list;

    // Apply status filter
    if (statusFilter != 'الكل') {
      filtered = filtered.where((tx) => tx.status == statusFilter).toList();
    }

    // Apply search query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((tx) {
        return tx.number.toLowerCase().contains(lowerQuery) ||
            tx.applicant.toLowerCase().contains(lowerQuery) ||
            tx.type.toLowerCase().contains(lowerQuery) ||
            tx.department.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    return filtered;
  }

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
