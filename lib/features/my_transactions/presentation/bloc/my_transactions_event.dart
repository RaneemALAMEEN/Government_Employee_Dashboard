abstract class MyTransactionsEvent {
  const MyTransactionsEvent();
}

class LoadMyTransactions extends MyTransactionsEvent {}

class FilterMyTransactions extends MyTransactionsEvent {
  final String statusFilter; // 'الكل', 'بانتظار الاستلام', 'قيد التنفيذ', 'منجزة', 'تم الرفض'
  const FilterMyTransactions(this.statusFilter);
}

class SearchMyTransactions extends MyTransactionsEvent {
  final String query;
  const SearchMyTransactions(this.query);
}

class SignTransaction extends MyTransactionsEvent {
  final String txnNumber;
  const SignTransaction(this.txnNumber);
}

class RejectTransaction extends MyTransactionsEvent {
  final String txnNumber;
  const RejectTransaction(this.txnNumber);
}

class PickupTransaction extends MyTransactionsEvent {
  final String txnNumber;
  const PickupTransaction(this.txnNumber);
}

class CancelPickupTransaction extends MyTransactionsEvent {
  final String txnNumber;
  const CancelPickupTransaction(this.txnNumber);
}
