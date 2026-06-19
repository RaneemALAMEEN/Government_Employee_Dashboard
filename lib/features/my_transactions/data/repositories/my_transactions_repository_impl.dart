import '../../domain/entities/my_transaction_entity.dart';
import '../../domain/repositories/my_transactions_repository.dart';
import '../datasources/my_transactions_remote_data_source.dart';
import '../models/my_transaction_model.dart';

class MyTransactionsRepositoryImpl implements MyTransactionsRepository {
  final MyTransactionsRemoteDataSource remoteDataSource;

  MyTransactionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<MyTransactionEntity>> getMyTransactions() async {
    final results = await Future.wait([
      remoteDataSource.getPendingPickupTasks(limit: 50),
      remoteDataSource.getInProgressTasks(limit: 50),
      remoteDataSource.getTasks(status: 'completed', limit: 50),
      remoteDataSource.getTasks(status: 'rejected', limit: 50),
    ]);

    final List<MyTransactionEntity> mergedList = [];
    final Set<String> numbers = {};

    for (final result in results) {
      result.fold(
        (failure) {
          throw Exception(failure.message);
        },
        (data) {
          if (data is Map && data['data'] != null && data['data']['items'] is List) {
            final itemsList = data['data']['items'] as List;
            for (final item in itemsList) {
              if (item is Map) {
                // Cast to Map<String, dynamic> safely
                final mapItem = Map<String, dynamic>.from(item);
                final model = MyTransactionModel.fromJson(mapItem);
                if (!numbers.contains(model.number)) {
                  numbers.add(model.number);
                  mergedList.add(model);
                }
              }
            }
          }
        },
      );
    }

    return mergedList;
  }
}
