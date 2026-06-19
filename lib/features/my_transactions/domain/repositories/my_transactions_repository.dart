import '../entities/my_transaction_entity.dart';

abstract class MyTransactionsRepository {
  Future<List<MyTransactionEntity>> getMyTransactions();
}
