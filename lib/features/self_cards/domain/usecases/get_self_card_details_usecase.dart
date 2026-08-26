import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/self_card_entity.dart';
import '../repositories/self_cards_repository.dart';

class GetSelfCardDetailsUseCase {
  final SelfCardsRepository repository;

  GetSelfCardDetailsUseCase(this.repository);

  Future<Either<Failure, SelfCardEntity>> call(int id) {
    return repository.getSelfCardDetails(id);
  }
}
