import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ChangePinUseCase {
  final AuthRepository repository;

  ChangePinUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String oldPin,
    required String newPin,
    required String confirmNewPin,
  }) {
    return repository.changePin(
      oldPin: oldPin,
      newPin: newPin,
      confirmNewPin: confirmNewPin,
    );
  }
}
