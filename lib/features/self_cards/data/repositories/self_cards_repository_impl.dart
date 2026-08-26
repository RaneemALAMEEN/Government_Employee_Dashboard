import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/self_card_entity.dart';
import '../../domain/entities/self_card_search_item_entity.dart';
import '../../domain/entities/training_recommendation_entity.dart';
import '../../domain/repositories/self_cards_repository.dart';
import '../datasources/self_cards_remote_data_source.dart';

class SelfCardsRepositoryImpl implements SelfCardsRepository {
  final SelfCardsRemoteDataSource remoteDataSource;

  SelfCardsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SelfCardSearchItemEntity>>> searchSelfCards({
    String? query,
    String? cursor,
    int limit = 20,
    bool activeOnly = true,
  }) async {
    try {
      final items = await remoteDataSource.searchSelfCards(
        query: query,
        cursor: cursor,
        limit: limit,
        activeOnly: activeOnly,
      );
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, SelfCardEntity>> getSelfCardDetails(int id) async {
    try {
      final card = await remoteDataSource.getSelfCardDetails(id);
      return Right(card);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, SelfCardEntity?>> getSelfCardByEmployeeId(
    int employeeId,
  ) async {
    try {
      final card = await remoteDataSource.getSelfCardByEmployeeId(employeeId);
      return Right(card);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, TrainingRecommendationResultEntity>> recommendByTraining({
    required String title,
    int limit = 20,
    String? publicEntity,
  }) async {
    try {
      final result = await remoteDataSource.recommendByTraining(
        title: title,
        limit: limit,
        publicEntity: publicEntity,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  String _cleanError(dynamic error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
