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
  final int completedCount;
  final int rejectedCount;
  final int activeCount;
  final int inProgressCount;
  final int pendingPickupCount;

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
    this.completedCount = 0,
    this.rejectedCount = 0,
    this.activeCount = 0,
    this.inProgressCount = 0,
    this.pendingPickupCount = 0,
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
    int? completedCount,
    int? rejectedCount,
    int? activeCount,
    int? inProgressCount,
    int? pendingPickupCount,
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
      completedCount: completedCount ?? this.completedCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      activeCount: activeCount ?? this.activeCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      pendingPickupCount: pendingPickupCount ?? this.pendingPickupCount,
    );
  }
}

class DeptTxFailure extends DeptTxState {
  final String message;
  const DeptTxFailure(this.message);
}
