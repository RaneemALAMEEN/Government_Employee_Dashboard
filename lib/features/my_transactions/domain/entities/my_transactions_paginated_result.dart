import '../entities/my_transaction_entity.dart';

/// نتيجة مُرقّمة (paginated) لقائمة المعاملات مع cursor pagination
class MyTransactionsPaginatedResult {
  final List<MyTransactionEntity> items;
  final String? nextCursor;
  final bool hasNext;
  final int totalCount;

  const MyTransactionsPaginatedResult({
    required this.items,
    this.nextCursor,
    this.hasNext = false,
    this.totalCount = 0,
  });
}
