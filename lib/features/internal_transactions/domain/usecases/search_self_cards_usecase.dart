import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/self_cards_search_result_entity.dart';
import '../repositories/internal_transactions_repository.dart';

class SearchSelfCardsUseCase {
  final InternalTransactionsRepository repository;

  const SearchSelfCardsUseCase(this.repository);

  Future<Either<Failure, SelfCardsSearchResultEntity>> call({
    String? query,
    String? cursor,
    int limit = 20,
    bool activeOnly = true,
  }) =>
      repository.searchSelfCards(
        query: query,
        cursor: cursor,
        limit: limit,
        activeOnly: activeOnly,
      );
}
