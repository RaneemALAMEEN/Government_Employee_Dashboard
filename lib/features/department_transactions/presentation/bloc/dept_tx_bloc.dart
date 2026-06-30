import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/department_transaction_entity.dart';
import '../../domain/usecases/get_department_transactions.dart';
import 'dept_tx_event.dart';
import 'dept_tx_state.dart';

class DeptTxBloc extends Bloc<DeptTxEvent, DeptTxState> {
  final GetDepartmentTransactions getDepartmentTransactions;

  DeptTxBloc(this.getDepartmentTransactions) : super(DeptTxInitial()) {
    on<LoadDeptTx>(_onLoadDeptTx);
    on<FilterDeptTxByStatus>(_onFilterDeptTxByStatus);
    on<FilterDeptTxByClassification>(_onFilterDeptTxByClassification);
    on<SearchDeptTx>(_onSearchDeptTx);
  }

  Future<void> _onLoadDeptTx(LoadDeptTx event, Emitter<DeptTxState> emit) async {
    emit(DeptTxLoading());
    try {
      final transactions = await getDepartmentTransactions();
      
      final total = transactions.length;
      final pending = transactions.where((tx) => tx.status == 'قيد الانتظار').length;
      final processing = transactions.where((tx) => tx.status == 'قيد المعالجة').length;
      final completed = transactions.where((tx) => tx.status == 'منجزة').length;

      emit(DeptTxLoaded(
        allTransactions: transactions,
        filteredTransactions: transactions,
        statusFilter: 'الكل',
        classificationFilter: 'الكل',
        searchQuery: '',
        totalCount: total,
        pendingCount: pending,
        processingCount: processing,
        completedCount: completed,
      ));
    } catch (e) {
      emit(DeptTxFailure(e.toString()));
    }
  }

  void _onFilterDeptTxByStatus(FilterDeptTxByStatus event, Emitter<DeptTxState> emit) {
    final currentState = state;
    if (currentState is DeptTxLoaded) {
      final filtered = _applyFilters(
        currentState.allTransactions,
        event.statusFilter,
        currentState.classificationFilter,
        currentState.searchQuery,
      );
      emit(currentState.copyWith(
        statusFilter: event.statusFilter,
        filteredTransactions: filtered,
      ));
    }
  }

  void _onFilterDeptTxByClassification(FilterDeptTxByClassification event, Emitter<DeptTxState> emit) {
    final currentState = state;
    if (currentState is DeptTxLoaded) {
      final filtered = _applyFilters(
        currentState.allTransactions,
        currentState.statusFilter,
        event.classificationFilter,
        currentState.searchQuery,
      );
      emit(currentState.copyWith(
        classificationFilter: event.classificationFilter,
        filteredTransactions: filtered,
      ));
    }
  }

  void _onSearchDeptTx(SearchDeptTx event, Emitter<DeptTxState> emit) {
    final currentState = state;
    if (currentState is DeptTxLoaded) {
      final filtered = _applyFilters(
        currentState.allTransactions,
        currentState.statusFilter,
        currentState.classificationFilter,
        event.query,
      );
      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredTransactions: filtered,
      ));
    }
  }

  List<DepartmentTransactionEntity> _applyFilters(
    List<DepartmentTransactionEntity> all,
    String status,
    String classification,
    String query,
  ) {
    return all.where((tx) {
      // 1. Status Filter
      if (status != 'الكل' && tx.status != status) {
        return false;
      }
      // 2. Classification Filter
      if (classification != 'الكل' && tx.classification != classification) {
        return false;
      }
      // 3. Search Query
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchesNum = tx.number.toLowerCase().contains(q);
        final matchesType = tx.type.toLowerCase().contains(q);
        final matchesAssigned = tx.assignedTo.toLowerCase().contains(q);
        return matchesNum || matchesType || matchesAssigned;
      }
      return true;
    }).toList();
  }
}
