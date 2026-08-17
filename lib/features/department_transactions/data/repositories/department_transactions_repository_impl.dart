import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../document_verification/data/models/document_verification_model.dart';
import '../../../document_verification/domain/entities/document_verification_entity.dart';
import '../../domain/entities/accessible_department_entity.dart';
import '../../domain/entities/source_documents_entity.dart';
import '../../domain/repositories/department_transactions_repository.dart';
import '../datasources/department_transactions_remote_data_source.dart';
import '../models/accessible_department_model.dart';
import '../models/department_transaction_model.dart';
import '../models/source_documents_model.dart';


class DepartmentTransactionsRepositoryImpl implements DepartmentTransactionsRepository {
  final DepartmentTransactionsRemoteDataSource remoteDataSource;

  const DepartmentTransactionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCompletedTransactions({
    String? departmentIds,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  }) async {
    final result = await remoteDataSource.getCompletedTransactions(
      departmentIds: departmentIds,
      fromDate: fromDate,
      toDate: toDate,
      cursor: cursor,
      limit: limit,
    );

    return result.map((data) => _mapResponse(data));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRejectedTransactions({
    String? departmentIds,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  }) async {
    final result = await remoteDataSource.getRejectedTransactions(
      departmentIds: departmentIds,
      fromDate: fromDate,
      toDate: toDate,
      cursor: cursor,
      limit: limit,
    );

    return result.map((data) => _mapResponse(data));
  }

  Map<String, dynamic> _mapResponse(dynamic data) {
    if (data is Map<String, dynamic> && data['data'] != null) {
      final itemsList = data['data']['items'] as List? ?? [];
      final transactions = itemsList
          .map((item) => DepartmentTransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      final pagination = data['data']['pagination'] as Map<String, dynamic>? ?? {};

      return {
        'items': transactions,
        'pagination': pagination,
      };
    }
    return {
      'items': <DepartmentTransactionModel>[],
      'pagination': <String, dynamic>{},
    };
  }

  @override
  Future<Either<Failure, DocumentVerificationEntity>> getTransactionCertificate(String transactionId) async {
    final result = await remoteDataSource.getTransactionCertificate(transactionId);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data is! Map) {
          return const Left(ServerFailure('استجابة تفاصيل المعاملة غير صالحة'));
        }
        try {
          final model = DocumentVerificationModel.fromJson(Map<String, dynamic>.from(data));
          return Right(model);
        } catch (e) {
          return Left(ServerFailure('فشل في تحليل بيانات تفاصيل المعاملة: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCompletedStatsLastMonth({required String departmentIds}) async {
    final result = await remoteDataSource.getCompletedStatsLastMonth(departmentIds: departmentIds);
    return result.map((data) {
      if (data is Map<String, dynamic> && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      return <String, dynamic>{};
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getRejectedStatsLastMonth({required String departmentIds}) async {
    final result = await remoteDataSource.getRejectedStatsLastMonth(departmentIds: departmentIds);
    return result.map((data) {
      if (data is Map<String, dynamic> && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      return <String, dynamic>{};
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getActiveStats({required String departmentIds}) async {
    final result = await remoteDataSource.getActiveStats(departmentIds: departmentIds);
    return result.map((data) {
      if (data is Map<String, dynamic> && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      return <String, dynamic>{};
    });
  }

  @override
  Future<Either<Failure, List<AccessibleDepartmentEntity>>> getAccessibleDepartments() async {
    final result = await remoteDataSource.getAccessibleScope();
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data is Map<String, dynamic> && data['data'] != null) {
          final departmentsList = data['data']['departments'] as List? ?? [];
          final departments = departmentsList
              .map((item) => AccessibleDepartmentModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          return Right(departments);
        }
        return const Right(<AccessibleDepartmentEntity>[]);
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> searchCompletedTransactions({
    required String departmentIds,
    String? query,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  }) async {
    final result = await remoteDataSource.searchCompletedTransactions(
      departmentIds: departmentIds,
      query: query,
      fromDate: fromDate,
      toDate: toDate,
      cursor: cursor,
      limit: limit,
    );

    return result.map((data) => _mapResponse(data));
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> searchRejectedTransactions({
    required String departmentIds,
    String? query,
    String? fromDate,
    String? toDate,
    String? cursor,
    int limit = 6,
  }) async {
    final result = await remoteDataSource.searchRejectedTransactions(
      departmentIds: departmentIds,
      query: query,
      fromDate: fromDate,
      toDate: toDate,
      cursor: cursor,
      limit: limit,
    );

    return result.map((data) => _mapResponse(data));
  }

  @override
  Future<Either<Failure, SourceDocumentsEntity>> getSourceDocuments(
      int transactionId) async {
    final result = await remoteDataSource.getSourceDocuments(transactionId);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data is! Map) {
          return const Left(ServerFailure('استجابة مستندات المعاملة غير صالحة'));
        }
        try {
          final model = SourceDocumentsModel.fromJson(
              Map<String, dynamic>.from(data));
          return Right(model);
        } catch (e) {
          return Left(
              ServerFailure('فشل في تحليل بيانات مستندات المعاملة: $e'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, GeneratedFinalDocumentResultEntity>>
      getOrGenerateFinalDocument(
    int transactionId, {
    String? fileOrder,
    String? documentSignatureIds,
    String? documentInstanceIds,
  }) async {
    final result = await remoteDataSource.getOrGenerateFinalDocument(
      transactionId,
      fileOrder: fileOrder,
      documentSignatureIds: documentSignatureIds,
      documentInstanceIds: documentInstanceIds,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) {
        try {
          final model = GeneratedFinalDocumentResultModel.fromJson(data);
          return Right(model);
        } catch (e) {
          return Left(
              ServerFailure('فشل في تحليل نتيجة توليد الوثيقة النهائية: $e'));
        }
      },
    );
  }
}

