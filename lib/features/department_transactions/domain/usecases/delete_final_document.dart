import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/department_transactions_repository.dart';

class DeleteFinalDocumentUseCase {
  final DepartmentTransactionsRepository repository;

  DeleteFinalDocumentUseCase(this.repository);

  Future<Either<Failure, String>> call(int transactionId) {
    return repository.deleteFinalDocument(transactionId);
  }
}
