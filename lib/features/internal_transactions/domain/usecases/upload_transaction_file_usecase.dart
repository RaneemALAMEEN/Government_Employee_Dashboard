import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;

import '../../../../core/errors/failures.dart';
import '../repositories/internal_transactions_repository.dart';

class UploadTransactionFileUseCase {
  final InternalTransactionsRepository repository;

  UploadTransactionFileUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String filePath,
    required int typeDocId,
    required String key,
    dio.ProgressCallback? onSendProgress,
  }) {
    return repository.uploadTransactionFile(
      filePath: filePath,
      typeDocId: typeDocId,
      key: key,
      onSendProgress: onSendProgress,
    );
  }
}