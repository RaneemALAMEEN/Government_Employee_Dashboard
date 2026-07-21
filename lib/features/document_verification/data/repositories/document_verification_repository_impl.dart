import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/document_verification_entity.dart';
import '../../domain/repositories/document_verification_repository.dart';
import '../datasources/document_verification_remote_data_source.dart';

class DocumentVerificationRepositoryImpl
    implements DocumentVerificationRepository {
  final DocumentVerificationRemoteDataSource remoteDataSource;

  const DocumentVerificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DocumentVerificationEntity>> verify(
    String code,
  ) async {
    try {
      return Right(await remoteDataSource.verify(code));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
