import '../../domain/entities/my_transaction_entity.dart';

abstract class MyTransactionsState {
  const MyTransactionsState();
}

class MyTransactionsInitial extends MyTransactionsState {}

class MyTransactionsLoading extends MyTransactionsState {}

class MyTransactionsLoaded extends MyTransactionsState {
  final List<MyTransactionEntity> transactions;
  final String statusFilter; // النص العربي للفلتر
  final String apiStatusFilter; // القيمة الإنجليزية المرسلة لل API
  final String searchQuery;

  // Pagination
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  // Cache counts
  final int awaitingSignatureCount;
  final int urgentCount;
  final int completedMonthCount;

  const MyTransactionsLoaded({
    required this.transactions,
    required this.statusFilter,
    required this.apiStatusFilter,
    required this.searchQuery,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    required this.awaitingSignatureCount,
    required this.urgentCount,
    required this.completedMonthCount,
  });

  MyTransactionsLoaded copyWith({
    List<MyTransactionEntity>? transactions,
    String? statusFilter,
    String? apiStatusFilter,
    String? searchQuery,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    int? awaitingSignatureCount,
    int? urgentCount,
    int? completedMonthCount,
  }) {
    return MyTransactionsLoaded(
      transactions: transactions ?? this.transactions,
      statusFilter: statusFilter ?? this.statusFilter,
      apiStatusFilter: apiStatusFilter ?? this.apiStatusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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
