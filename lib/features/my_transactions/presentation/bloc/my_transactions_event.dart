abstract class MyTransactionsEvent {
  const MyTransactionsEvent();
}

/// تحميل المعاملات (أول صفحة) — يُستخدم عند فتح الشاشة أو تغيير الفلتر
class LoadMyTransactions extends MyTransactionsEvent {
  final String apiStatus; // 'all', 'pending_pickup', 'in_progress', 'completed', 'rejected'
  const LoadMyTransactions({this.apiStatus = 'all'});
}

/// تحميل المزيد من المعاملات (infinite scroll)
class LoadMoreTransactions extends MyTransactionsEvent {}

/// تغيير الفلتر — يعيد التحميل من الصفر مع الفلتر الجديد
class FilterMyTransactions extends MyTransactionsEvent {
  final String statusFilter; // النص العربي: 'الكل', 'بانتظار الاستلام', etc.
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
