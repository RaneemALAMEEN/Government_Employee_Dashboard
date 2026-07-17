import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/internal_transactions_repository.dart';

class CreateSigningChallengeUseCase {
  final InternalTransactionsRepository repository;

  CreateSigningChallengeUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required int processId,
    required String pin,
  }) {
    return repository.createSigningChallenge(
      processId: processId,
      pin: pin,
    );
  }
}
