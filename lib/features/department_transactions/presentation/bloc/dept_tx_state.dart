import '../../domain/entities/department_transaction_entity.dart';

abstract class DeptTxState {
  const DeptTxState();
}

class DeptTxInitial extends DeptTxState {}

class DeptTxLoading extends DeptTxState {}

class DeptTxLoaded extends DeptTxState {
  final List<DepartmentTransactionEntity> transactions;
  final String statusFilter;
  final String? fromDate;
  final String? toDate;
  final String searchQuery;
  final int page;
  final bool hasReachedMax;
  final bool isFetchingMore;
  
  // Stats
  final int totalCount;

  const DeptTxLoaded({
    required this.transactions,
    required this.statusFilter,
    this.fromDate,
    this.toDate,
    required this.searchQuery,
    required this.page,
    required this.hasReachedMax,
    this.isFetchingMore = false,
    required this.totalCount,
  });

  DeptTxLoaded copyWith({
    List<DepartmentTransactionEntity>? transactions,
    String? statusFilter,
    String? fromDate,
    String? toDate,
    String? searchQuery,
    int? page,
    bool? hasReachedMax,
    bool? isFetchingMore,
    int? totalCount,
  }) {
    return DeptTxLoaded(
      transactions: transactions ?? this.transactions,
      statusFilter: statusFilter ?? this.statusFilter,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class DeptTxFailure extends DeptTxState {
  final String message;
  const DeptTxFailure(this.message);
}
