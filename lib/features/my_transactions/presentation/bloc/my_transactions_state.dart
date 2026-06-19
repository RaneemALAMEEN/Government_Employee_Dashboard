import '../../domain/entities/my_transaction_entity.dart';

abstract class MyTransactionsState {
  const MyTransactionsState();
}

class MyTransactionsInitial extends MyTransactionsState {}

class MyTransactionsLoading extends MyTransactionsState {}

class MyTransactionsLoaded extends MyTransactionsState {
  final List<MyTransactionEntity> allTransactions;
  final List<MyTransactionEntity> filteredTransactions;
  final String statusFilter;
  final String searchQuery;

  // Cache counts
  final int awaitingSignatureCount;
  final int urgentCount;
  final int completedMonthCount;

  const MyTransactionsLoaded({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.statusFilter,
    required this.searchQuery,
    required this.awaitingSignatureCount,
    required this.urgentCount,
    required this.completedMonthCount,
  });

  MyTransactionsLoaded copyWith({
    List<MyTransactionEntity>? allTransactions,
    List<MyTransactionEntity>? filteredTransactions,
    String? statusFilter,
    String? searchQuery,
    int? awaitingSignatureCount,
    int? urgentCount,
    int? completedMonthCount,
  }) {
    return MyTransactionsLoaded(
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      awaitingSignatureCount: awaitingSignatureCount ?? this.awaitingSignatureCount,
      urgentCount: urgentCount ?? this.urgentCount,
      completedMonthCount: completedMonthCount ?? this.completedMonthCount,
    );
  }
}

class MyTransactionsFailure extends MyTransactionsState {
  final String message;
  const MyTransactionsFailure(this.message);
}
