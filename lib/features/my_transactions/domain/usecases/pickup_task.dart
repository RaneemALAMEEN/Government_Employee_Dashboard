import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/my_transactions_repository.dart';

class PickupTask {
  final MyTransactionsRepository repository;

  PickupTask(this.repository);

  Future<Either<Failure, dynamic>> call({required String taskId}) async {
    return await repository.pickupTask(taskId: taskId);
  }
}
