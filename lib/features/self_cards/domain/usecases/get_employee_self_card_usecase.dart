import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/self_card_entity.dart';
import '../repositories/self_cards_repository.dart';

class GetEmployeeSelfCardUseCase {
  final SelfCardsRepository repository;

  GetEmployeeSelfCardUseCase(this.repository);

  Future<Either<Failure, SelfCardEntity?>> call(int employeeId) {
    return repository.getSelfCardByEmployeeId(employeeId);
  }
}
