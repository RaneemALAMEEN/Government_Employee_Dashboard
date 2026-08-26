import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/document_template_entity.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dynamic_form_entity.dart';
import '../../domain/entities/internal_category_entity.dart';
import '../../domain/entities/internal_processes_page_entity.dart';
import '../../domain/entities/internal_transaction_first_stage_entity.dart';
import '../../domain/entities/internal_transaction_counts_entity.dart';
import '../../domain/entities/internal_transactions_page_entity.dart';
import '../../domain/entities/self_card_entity.dart';
import '../../domain/entities/self_cards_search_result_entity.dart';
import '../../domain/repositories/internal_transactions_repository.dart';
import '../datasources/internal_transactions_remote_data_source.dart';

class InternalTransactionsRepositoryImpl
    implements InternalTransactionsRepository {
  final InternalTransactionsRemoteDataSource remoteDataSource;

  InternalTransactionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<InternalCategoryEntity>>> getCategories() async {
    try {
      final data = await remoteDataSource.getCategories();
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, InternalProcessesPageEntity>> getProcessesByCategory({
    required int categoryId,
    required int page,
    required int limit,
  }) async {
    try {
      final data = await remoteDataSource.getProcessesByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, InternalTransactionCountsEntity>>
      getMyTransactionCounts() async {
    try {
      final data = await remoteDataSource.getMyTransactionCounts();
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, InternalTransactionsPageEntity>> getMyTransactions({
    required int page,
    required int limit,
    String? status,
  }) async {
    try {
      final data = await remoteDataSource.getMyTransactions(
        page: page,
        limit: limit,
        status: status,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, InternalTransactionFirstStageEntity>>
      getFirstStageTransaction({
    required int transactionId,
  }) async {
    try {
      final data = await remoteDataSource.getFirstStageTransaction(
        transactionId: transactionId,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, DynamicFormEntity>> getStageConfig({
    required int processId,
  }) async {
    try {
      final data = await remoteDataSource.getStageConfig(processId: processId);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, SelfCardsSearchResultEntity>> searchSelfCards({
    String? query,
    String? cursor,
    required int limit,
    required bool activeOnly,
  }) async {
    try {
      return Right(await remoteDataSource.searchSelfCards(
        query: query,
        cursor: cursor,
        limit: limit,
        activeOnly: activeOnly,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, SelfCardDetailsEntity>> getSelfCardDetails({
    required int id,
  }) async {
    try {
      return Right(await remoteDataSource.getSelfCardDetails(id: id));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadTransactionFile({
    required String filePath,
    required int typeDocId,
    required String key,
    dio.ProgressCallback? onSendProgress,
  }) async {
    try {
      final data = await remoteDataSource.uploadTransactionFile(
        filePath: filePath,
        typeDocId: typeDocId,
        key: key,
        onSendProgress: onSendProgress,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createSigningChallenge({
    required int processId,
    required String pin,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final data = await remoteDataSource.createSigningChallenge(
        processId: processId,
        pin: pin,
        payload: payload,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeSignedTransaction({
    required int transactionId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final data = await remoteDataSource.completeSignedTransaction(
        transactionId: transactionId,
        payload: payload,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Future<Either<Failure, DocumentTemplateEntity>> getDocumentTemplate({
    required int templateId,
  }) async {
    try {
      final data = await remoteDataSource.getDocumentTemplate(
        templateId: templateId,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }
}
