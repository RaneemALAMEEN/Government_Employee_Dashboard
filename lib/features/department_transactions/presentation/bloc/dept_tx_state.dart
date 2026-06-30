import '../../domain/entities/department_transaction_entity.dart';

abstract class DeptTxState {
  const DeptTxState();
}

class DeptTxInitial extends DeptTxState {}

class DeptTxLoading extends DeptTxState {}

class DeptTxLoaded extends DeptTxState {
  final List<DepartmentTransactionEntity> allTransactions;
  final List<DepartmentTransactionEntity> filteredTransactions;
  final String statusFilter;
  final String classificationFilter;
  final String searchQuery;

  // Stats
  final int totalCount;
  final int pendingCount;
  final int processingCount;
  final int completedCount;

  const DeptTxLoaded({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.statusFilter,
    required this.classificationFilter,
    required this.searchQuery,
    required this.totalCount,
    required this.pendingCount,
    required this.processingCount,
    required this.completedCount,
  });

  DeptTxLoaded copyWith({
    List<DepartmentTransactionEntity>? allTransactions,
    List<DepartmentTransactionEntity>? filteredTransactions,
    String? statusFilter,
    String? classificationFilter,
    String? searchQuery,
    int? totalCount,
    int? pendingCount,
    int? processingCount,
    int? completedCount,
  }) {
    return DeptTxLoaded(
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      statusFilter: statusFilter ?? this.statusFilter,
      classificationFilter: classificationFilter ?? this.classificationFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      totalCount: totalCount ?? this.totalCount,
      pendingCount: pendingCount ?? this.pendingCount,
      processingCount: processingCount ?? this.processingCount,
      completedCount: completedCount ?? this.completedCount,
    );
  }
}

class DeptTxFailure extends DeptTxState {
  final String message;
  const DeptTxFailure(this.message);
}
