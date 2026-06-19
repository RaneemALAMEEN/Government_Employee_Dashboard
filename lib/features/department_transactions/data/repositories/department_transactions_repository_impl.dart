import '../../domain/entities/department_transaction_entity.dart';
import '../../domain/repositories/department_transactions_repository.dart';
import '../datasources/department_transactions_local_data_source.dart';

class DepartmentTransactionsRepositoryImpl implements DepartmentTransactionsRepository {
  final DepartmentTransactionsLocalDataSource localDataSource;

  const DepartmentTransactionsRepositoryImpl(this.localDataSource);

  @override
  Future<List<DepartmentTransactionEntity>> getDepartmentTransactions() async {
    return await localDataSource.getDepartmentTransactions();
  }
}
