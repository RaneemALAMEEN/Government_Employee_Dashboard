abstract class DeptTxEvent {
  const DeptTxEvent();
}

class LoadDeptTx extends DeptTxEvent {
  final bool isRefresh;
  const LoadDeptTx({this.isRefresh = false});
}

class LoadMoreDeptTx extends DeptTxEvent {}

class FilterDeptTxByStatus extends DeptTxEvent {
  final String statusFilter; // 'منجزة', 'مرفوضة'
  const FilterDeptTxByStatus(this.statusFilter);
}

class FilterDeptTxByDate extends DeptTxEvent {
  final String? fromDate;
  final String? toDate;
  const FilterDeptTxByDate({this.fromDate, this.toDate});
}

class SearchDeptTx extends DeptTxEvent {
  final String query;
  const SearchDeptTx(this.query);
}
