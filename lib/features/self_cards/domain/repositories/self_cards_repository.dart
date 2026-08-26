import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/self_card_entity.dart';
import '../entities/self_card_search_item_entity.dart';
import '../entities/training_recommendation_entity.dart';

abstract class SelfCardsRepository {
  Future<Either<Failure, List<SelfCardSearchItemEntity>>> searchSelfCards({
    String? query,
    String? cursor,
    int limit = 20,
    bool activeOnly = true,
  });

  Future<Either<Failure, SelfCardEntity>> getSelfCardDetails(int id);

  Future<Either<Failure, SelfCardEntity?>> getSelfCardByEmployeeId(
    int employeeId,
  );

  Future<Either<Failure, TrainingRecommendationResultEntity>> recommendByTraining({
    required String title,
    int limit = 20,
    String? publicEntity,
  });
}

