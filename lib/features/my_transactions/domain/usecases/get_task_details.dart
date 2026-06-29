import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/my_transactions_repository.dart';

class GetTaskDetails {
  final MyTransactionsRepository repository;

  GetTaskDetails(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({required String taskId}) async {
    return await repository.getTaskDetails(taskId: taskId);
  }
}
