import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/internal_transactions_repository.dart';

class UploadTransactionFileUseCase {
  final InternalTransactionsRepository repository;

  UploadTransactionFileUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String filePath,
    required int typeDocId,
    required String key,
  }) {
    return repository.uploadTransactionFile(
      filePath: filePath,
      typeDocId: typeDocId,
      key: key,
    );
  }
}