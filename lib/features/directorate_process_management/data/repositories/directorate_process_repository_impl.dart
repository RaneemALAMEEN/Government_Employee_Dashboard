import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/process_details_entity.dart';
import '../../domain/entities/process_definitions_response_entity.dart';
import '../../domain/entities/transaction_type_entity.dart';
import '../../domain/repositories/directorate_process_repository.dart';
import '../datasources/directorate_process_remote_data_source.dart';

class DirectorateProcessRepositoryImpl implements DirectorateProcessRepository {
  final DirectorateProcessRemoteDataSource remoteDataSource;
  const DirectorateProcessRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<TransactionTypeEntity>>>
      getTransactionTypes() async {
    try {
      return Right(await remoteDataSource.getTransactionTypes());
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, ProcessDefinitionsResponseEntity>>
      getProcessDefinitions({
    required int typeId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return Right(await remoteDataSource.getProcessDefinitions(
        typeId: typeId,
        page: page,
        limit: limit,
      ));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, ProcessDetailsEntity>> getProcessDetails({
    required int processId,
  }) async {
    try {
      return Right(
        await remoteDataSource.getProcessDetails(processId: processId),
      );
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, ProcessDefinitionsResponseEntity>>
      getComplaintProcessDefinitions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      return Right(
        await remoteDataSource.getComplaintProcessDefinitions(
          page: page,
          limit: limit,
        ),
      );
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
