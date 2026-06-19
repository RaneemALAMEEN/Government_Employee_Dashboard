import '../entities/my_transaction_entity.dart';
import '../repositories/my_transactions_repository.dart';

class GetMyTransactions {
  final MyTransactionsRepository repository;

  GetMyTransactions(this.repository);

  Future<List<MyTransactionEntity>> call() {
    return repository.getMyTransactions();
  }
}
