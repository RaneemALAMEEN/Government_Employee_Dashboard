import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/my_transactions_repository.dart';

class ReleaseTask {
  final MyTransactionsRepository repository;

  ReleaseTask(this.repository);

  Future<Either<Failure, dynamic>> call({required String taskId}) async {
    return await repository.releaseTask(taskId: taskId);
  }
}
