abstract class DeptTxEvent {
  const DeptTxEvent();
}

class LoadDeptTx extends DeptTxEvent {}

class FilterDeptTxByStatus extends DeptTxEvent {
  final String statusFilter; // 'الكل', 'قيد الانتظار', 'قيد المعالجة', 'منجزة', 'مرفوضة'
  const FilterDeptTxByStatus(this.statusFilter);
}

class FilterDeptTxByClassification extends DeptTxEvent {
  final String classificationFilter; // 'الكل', 'الموارد البشرية', 'التعليم الأساسي', etc.
  const FilterDeptTxByClassification(this.classificationFilter);
}

class SearchDeptTx extends DeptTxEvent {
  final String query;
  const SearchDeptTx(this.query);
}
