import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/self_card_search_item_entity.dart';
import '../repositories/self_cards_repository.dart';

class SearchSelfCardsUseCase {
  final SelfCardsRepository repository;

  SearchSelfCardsUseCase(this.repository);

  Future<Either<Failure, List<SelfCardSearchItemEntity>>> call({
    String? query,
    String? cursor,
    int limit = 20,
    bool activeOnly = true,
  }) {
    return repository.searchSelfCards(
      query: query,
      cursor: cursor,
      limit: limit,
      activeOnly: activeOnly,
    );
  }
}
