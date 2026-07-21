import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/document_verification_entity.dart';
import '../repositories/document_verification_repository.dart';

class VerifyDocument {
  final DocumentVerificationRepository repository;

  const VerifyDocument(this.repository);

  Future<Either<Failure, DocumentVerificationEntity>> call(String code) =>
      repository.verify(code);
}
