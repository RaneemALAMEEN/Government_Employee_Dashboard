import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../document_verification/domain/entities/document_verification_entity.dart';
import '../entities/accessible_department_entity.dart';
import '../entities/source_documents_entity.dart';


abstract class DepartmentTransactionsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getCompletedTransactions({
    String? departmentIds,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  });

  Future<Either<Failure, Map<String, dynamic>>> getRejectedTransactions({
    String? departmentIds,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  });

  Future<Either<Failure, DocumentVerificationEntity>> getTransactionCertificate(
      String transactionId);

  Future<Either<Failure, Map<String, dynamic>>> getCompletedStatsLastMonth(
      {required String departmentIds});
  Future<Either<Failure, Map<String, dynamic>>> getRejectedStatsLastMonth(
      {required String departmentIds});
  Future<Either<Failure, Map<String, dynamic>>> getActiveStats(
      {required String departmentIds});

  Future<Either<Failure, List<AccessibleDepartmentEntity>>> getAccessibleDepartments();

  Future<Either<Failure, Map<String, dynamic>>> searchCompletedTransactions({
    required String departmentIds,
    String? query,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  });

  Future<Either<Failure, Map<String, dynamic>>> searchRejectedTransactions({
    required String departmentIds,
    String? query,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  });

  Future<Either<Failure, SourceDocumentsEntity>> getSourceDocuments(
      int transactionId);

  Future<Either<Failure, GeneratedFinalDocumentResultEntity>>
      getOrGenerateFinalDocument(
    int transactionId, {
    String? fileOrder,
    String? documentSignatureIds,
    String? documentInstanceIds,
  });
}


