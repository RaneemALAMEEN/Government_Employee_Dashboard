import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/document_verification_entity.dart';

abstract class DocumentVerificationRepository {
  Future<Either<Failure, DocumentVerificationEntity>> verify(String code);
}
