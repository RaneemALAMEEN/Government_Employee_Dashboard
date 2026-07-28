import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyAppPinUseCase {
  final AuthRepository repository;

  VerifyAppPinUseCase(this.repository);

  Future<Either<Failure, void>> call(String pin) {
    return repository.verifyAppPin(pin);
  }
}
