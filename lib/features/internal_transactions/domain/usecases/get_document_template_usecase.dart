import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/document_template_entity.dart';
import '../repositories/internal_transactions_repository.dart';

class GetDocumentTemplateUseCase {
  final InternalTransactionsRepository repository;

  GetDocumentTemplateUseCase(this.repository);

  Future<Either<Failure, DocumentTemplateEntity>> call({
    required int templateId,
  }) {
    return repository.getDocumentTemplate(
      templateId: templateId,
    );
  }
}