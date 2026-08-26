import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/self_card_entity.dart';
import '../repositories/internal_transactions_repository.dart';

class GetSelfCardDetailsUseCase {
  final InternalTransactionsRepository repository;

  const GetSelfCardDetailsUseCase(this.repository);

  Future<Either<Failure, SelfCardDetailsEntity>> call({required int id}) =>
      repository.getSelfCardDetails(id: id);
}
