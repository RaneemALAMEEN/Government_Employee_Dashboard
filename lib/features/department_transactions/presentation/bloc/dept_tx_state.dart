import '../../domain/entities/accessible_department_entity.dart';
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
  final String? nextCursor;
  final bool hasReachedMax;
  final bool isFetchingMore;
  
  // Stats
  final int totalCount;
  final int completedCount;
  final int rejectedCount;
  final int activeCount;
  final int inProgressCount;
  final int pendingPickupCount;

  // Accessible departments
  final List<AccessibleDepartmentEntity> accessibleDepartments;
  final int? selectedDepartmentId;
  final String? selectedDepartmentName;

  // Search Loading Flag
  final bool isSearching;

  const DeptTxLoaded({
    required this.transactions,
    required this.statusFilter,
    this.fromDate,
    this.toDate,
    required this.searchQuery,
    this.nextCursor,
    required this.hasReachedMax,
    this.isFetchingMore = false,
    required this.totalCount,
    this.completedCount = 0,
    this.rejectedCount = 0,
    this.activeCount = 0,
    this.inProgressCount = 0,
    this.pendingPickupCount = 0,
    this.accessibleDepartments = const [],
    this.selectedDepartmentId,
    this.selectedDepartmentName,
    this.isSearching = false,
  });

  DeptTxLoaded copyWith({
    List<DepartmentTransactionEntity>? transactions,
    String? statusFilter,
    String? fromDate,
    String? toDate,
    String? searchQuery,
    String? nextCursor,
    bool? hasReachedMax,
    bool? isFetchingMore,
    int? totalCount,
    int? completedCount,
    int? rejectedCount,
    int? activeCount,
    int? inProgressCount,
    int? pendingPickupCount,
    List<AccessibleDepartmentEntity>? accessibleDepartments,
    int? selectedDepartmentId,
    String? selectedDepartmentName,
    bool? isSearching,
  }) {
    return DeptTxLoaded(
      transactions: transactions ?? this.transactions,
      statusFilter: statusFilter ?? this.statusFilter,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      searchQuery: searchQuery ?? this.searchQuery,
      nextCursor: nextCursor ?? this.nextCursor,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      totalCount: totalCount ?? this.totalCount,
      completedCount: completedCount ?? this.completedCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      activeCount: activeCount ?? this.activeCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      pendingPickupCount: pendingPickupCount ?? this.pendingPickupCount,
      accessibleDepartments: accessibleDepartments ?? this.accessibleDepartments,
      selectedDepartmentId: selectedDepartmentId ?? this.selectedDepartmentId,
      selectedDepartmentName: selectedDepartmentName ?? this.selectedDepartmentName,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class DeptTxFailure extends DeptTxState {
  final String message;
  const DeptTxFailure(this.message);
}
