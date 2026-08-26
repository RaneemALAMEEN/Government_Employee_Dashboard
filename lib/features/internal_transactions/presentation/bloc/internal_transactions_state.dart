import 'package:equatable/equatable.dart';

import '../../domain/entities/internal_transaction_counts_entity.dart';
import '../../domain/entities/internal_transactions_page_entity.dart';

class InternalTransactionsState extends Equatable {
  final bool loadingCounts;
  final bool loadingTransactions;
  final bool hasMoreTransactions;
  final String? errorMessage;
  final InternalTransactionCountsEntity counts;
  final InternalTransactionsPageEntity? transactionsPageData;
  final String searchQuery;
  final String statusFilter;

  const InternalTransactionsState({
    required this.loadingCounts,
    required this.loadingTransactions,
    required this.hasMoreTransactions,
    required this.counts,
    this.errorMessage,
    this.transactionsPageData,
    this.searchQuery = '',
    this.statusFilter = 'الكل',
  });

  factory InternalTransactionsState.initial() {
    return const InternalTransactionsState(
      loadingCounts: true,
      loadingTransactions: true,
      hasMoreTransactions: true,
      counts: InternalTransactionCountsEntity(
        total: 0,
        inProgress: 0,
        completed: 0,
      ),
      searchQuery: '',
      statusFilter: 'الكل',
    );
  }

  InternalTransactionsState copyWith({
    bool? loadingCounts,
    bool? loadingTransactions,
    bool? hasMoreTransactions,
    String? errorMessage,
    bool clearError = false,
    InternalTransactionCountsEntity? counts,
    InternalTransactionsPageEntity? transactionsPageData,
    String? searchQuery,
    String? statusFilter,
  }) {
    return InternalTransactionsState(
      loadingCounts: loadingCounts ?? this.loadingCounts,
      loadingTransactions: loadingTransactions ?? this.loadingTransactions,
      hasMoreTransactions: hasMoreTransactions ?? this.hasMoreTransactions,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      counts: counts ?? this.counts,
      transactionsPageData: transactionsPageData ?? this.transactionsPageData,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  @override
  List<Object?> get props => [
        loadingCounts,
        loadingTransactions,
        hasMoreTransactions,
        errorMessage,
        counts,
        transactionsPageData,
        searchQuery,
        statusFilter,
      ];
}
