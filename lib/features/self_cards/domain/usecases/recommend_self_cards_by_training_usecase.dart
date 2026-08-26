import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/training_recommendation_entity.dart';
import '../repositories/self_cards_repository.dart';

class RecommendSelfCardsByTrainingUseCase {
  final SelfCardsRepository repository;

  const RecommendSelfCardsByTrainingUseCase(this.repository);

  Future<Either<Failure, TrainingRecommendationResultEntity>> call({
    required String title,
    int limit = 20,
    String? publicEntity,
  }) {
    return repository.recommendByTraining(
      title: title,
      limit: limit,
      publicEntity: publicEntity,
    );
  }
}
